// (c) 2024, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";
import {Context} from "@openzeppelin/contracts@5.0.2/utils/Context.sol";

import {SafeERC20TransferFrom} from "@avalanche-icm/contracts@1.0.8/utilities/SafeERC20TransferFrom.sol";
import {IERC20SendAndCallReceiver} from "@avalanche-icm/contracts@1.0.8/ictt/interfaces/IERC20SendAndCallReceiver.sol";
import {IWrappedNativeToken} from "@avalanche-icm/contracts@1.0.8/ictt/interfaces/IWrappedNativeToken.sol";

import {IPoolManager} from "@uniswap/v4-core/contracts@4.0.0/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts@4.0.0/types/PoolKey.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts@4.0.0/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts@4.0.0/types/PoolId.sol";
import {IHooks} from "@uniswap/v4-core/contracts@4.0.0/interfaces/IHooks.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts@4.0.0/types/BalanceDelta.sol";
import {StateLibrary} from "@uniswap/v4-core/contracts@4.0.0/libraries/StateLibrary.sol";
import {TickMath} from "@uniswap/v4-core/contracts@4.0.0/libraries/TickMath.sol";

contract UniswapDexERC20Bridge is Context, IERC20SendAndCallReceiver {
    using SafeERC20 for IERC20;
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;

    address public immutable wNative;
    IPoolManager public immutable poolManager;

    // Default fee tier (0.3%)
    uint24 public constant DEFAULT_FEE = 3000;

    struct SwapOptions {
        address tokenOut;
        uint256 minAmountOut;
        uint24 fee; // Fee tier for the pool
    }

    constructor(address wrappedNativeAddress, address poolManagerAddress) {
        wNative = wrappedNativeAddress;
        poolManager = IPoolManager(poolManagerAddress);
    }

    event TokensReceived(
        bytes32 indexed sourceBlockchainID,
        address indexed originTokenTransferrerAddress,
        address indexed originSenderAddress,
        address token,
        uint256 amount,
        bytes payload
    );

    // To receive native when another contract called.
    receive() external payable {}

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }
        return
            PoolKey({
                currency0: Currency.wrap(tokenA),
                currency1: Currency.wrap(tokenB),
                fee: fee,
                tickSpacing: getTickSpacing(fee),
                hooks: IHooks(address(0)) // No hooks for basic swap
            });
    }

    function getTickSpacing(uint24 fee) internal pure returns (int24) {
        if (fee == 500) return 10;
        if (fee == 3000) return 60;
        if (fee == 10000) return 200;
        return 60; // Default to 60 for 0.3% fee
    }

    function _query(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        uint24 fee
    ) internal view returns (uint256 amountOut) {
        if (tokenIn == tokenOut || amountIn == 0) {
            return 0;
        }

        PoolKey memory poolKey = getPoolKey(tokenIn, tokenOut, fee);
        PoolId poolId = poolKey.toId();

        // Check if pool exists
        (uint160 sqrtPriceX96, , , ) = poolManager.getSlot0(poolId);
        if (sqrtPriceX96 == 0) {
            return 0; // Pool doesn't exist
        }

        // Get pool liquidity
        uint128 liquidity = poolManager.getLiquidity(poolId);
        if (liquidity == 0) {
            return 0; // No liquidity
        }

        // Calculate expected output using the current price
        // This is a simplified calculation - in production you'd want more precise math
        bool zeroForOne = tokenIn < tokenOut;
        // int24 currentTick = TickMath.getTickAtSqrtPrice(0);

        // Estimate output amount based on current price
        // Note: This is simplified - actual V4 quote would require more complex calculations
        uint256 price = (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) >>
            (96 * 2);
        if (zeroForOne) {
            amountOut = (amountIn * price) >> 192;
        } else {
            amountOut = (amountIn << 192) / price;
        }

        // Apply fee (simplified)
        amountOut = (amountOut * (1000000 - fee)) / 1000000;
    }

    function _swap(
        uint256 amountIn,
        uint256 minAmountOut,
        address tokenIn,
        address tokenOut,
        address to,
        uint24 fee
    ) internal returns (uint256 amountOut) {
        PoolKey memory poolKey = getPoolKey(tokenIn, tokenOut, fee);
        bool zeroForOne = tokenIn < tokenOut;

        // Approve the pool manager to spend tokens
        IERC20(tokenIn).approve(address(poolManager), amountIn);

        // Prepare swap parameters
        IPoolManager.SwapParams memory swapParams = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: -int256(amountIn), // Exact input
            sqrtPriceLimitX96: zeroForOne
                ? TickMath.MIN_SQRT_PRICE + 1
                : TickMath.MAX_SQRT_PRICE - 1
        });

        // Execute the swap
        BalanceDelta delta = poolManager.swap(poolKey, swapParams, "");

        // Extract the output amount
        amountOut = zeroForOne
            ? uint256(int256(-delta.amount1()))
            : uint256(int256(-delta.amount0()));

        require(
            amountOut >= minAmountOut,
            "UniswapDexERC20Bridge: insufficient output amount"
        );

        // Transfer output tokens to recipient
        if (to != address(this)) {
            IERC20(tokenOut).safeTransfer(to, amountOut);
        }
    }

    function receiveTokens(
        bytes32 sourceBlockchainID,
        address originTokenTransferrerAddress,
        address originSenderAddress,
        address token,
        uint256 amount,
        bytes calldata payload
    ) external {
        emit TokensReceived({
            sourceBlockchainID: sourceBlockchainID,
            originTokenTransferrerAddress: originTokenTransferrerAddress,
            originSenderAddress: originSenderAddress,
            token: token,
            amount: amount,
            payload: payload
        });

        require(payload.length > 0, "UniswapDexERC20Bridge: empty payload");

        IERC20 _token = IERC20(token);
        // Receives teleported assets to be used for different purposes.
        SafeERC20TransferFrom.safeTransferFrom(_token, _msgSender(), amount);

        // Parses the payload of the message.
        SwapOptions memory swapOptions = abi.decode(payload, (SwapOptions));

        // Use provided fee or default
        uint24 fee = swapOptions.fee > 0 ? swapOptions.fee : DEFAULT_FEE;

        // Requests a quote from the Uniswap V4 pool.
        uint256 amountOut = _query(amount, token, wNative, fee);
        require(amountOut > 0, "UniswapDexERC20Bridge: insufficient liquidity");

        // Checks if the target swap price is still valid.
        require(
            amountOut >= swapOptions.minAmountOut,
            "UniswapDexERC20Bridge: slippage exceeded"
        );

        // Execute the swap
        uint256 actualAmountOut = _swap(
            amount,
            swapOptions.minAmountOut,
            token,
            wNative,
            address(this),
            fee
        );

        // Verifies if the desired tokenOut is a native or wrapped asset.
        if (swapOptions.tokenOut == address(0)) {
            // User wants native token
            IWrappedNativeToken(wNative).withdraw(actualAmountOut);
            payable(originSenderAddress).transfer(actualAmountOut);
        } else {
            // User wants wrapped token, transfer directly
            IERC20(wNative).safeTransfer(originSenderAddress, actualAmountOut);
        }
    }
}
