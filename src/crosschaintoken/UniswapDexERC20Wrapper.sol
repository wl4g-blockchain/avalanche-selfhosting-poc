// (c) 2024, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";
import {Context} from "@openzeppelin/contracts@5.0.2/utils/Context.sol";

import {SafeERC20TransferFrom} from "@avalanche-icm/contracts@1.0.8/utilities/SafeERC20TransferFrom.sol";
import {IERC20SendAndCallReceiver} from "@avalanche-icm/contracts@1.0.8/ictt/interfaces/IERC20SendAndCallReceiver.sol";
import {IWrappedNativeToken} from "@avalanche-icm/contracts@1.0.8/ictt/interfaces/IWrappedNativeToken.sol";

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts@1.0.1/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts@1.0.1/interfaces/IUniswapV2Pair.sol";

contract UniswapDexERC20Wrapper is Context, IERC20SendAndCallReceiver {
    using SafeERC20 for IERC20;

    address public immutable wNative;
    address public immutable factory;

    struct SwapOptions {
        address tokenOut;
        uint256 minAmountOut;
    }

    constructor(address wrappedNativeAddress, address dexFactoryAddress) {
        wNative = wrappedNativeAddress;
        factory = dexFactoryAddress;
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

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1e3 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function query(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) internal view returns (uint256 amountOut) {
        if (tokenIn == tokenOut || amountIn == 0) {
            return 0;
        }
        address pair = IUniswapV2Factory(factory).getPair(tokenIn, tokenOut);
        if (pair == address(0)) {
            return 0;
        }
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(pair).getReserves();
        (uint256 reserveIn, uint256 reserveOut) = tokenIn < tokenOut
            ? (r0, r1)
            : (r1, r0);
        if (reserveIn > 0 && reserveOut > 0) {
            amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        }
    }

    function swap(
        uint256 amountIn,
        uint256 amountOut,
        address tokenIn,
        address tokenOut,
        address to
    ) internal {
        address pair = IUniswapV2Factory(factory).getPair(tokenIn, tokenOut);
        (uint256 amount0Out, uint256 amount1Out) = (tokenIn < tokenOut)
            ? (uint256(0), amountOut)
            : (amountOut, uint256(0));
        IERC20(tokenIn).safeTransfer(pair, amountIn);
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, to, new bytes(0));
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

        require(payload.length > 0, "UniswapDexERC20Wrapper: empty payload");

        IERC20 _token = IERC20(token);
        // Receives teleported assets to be used for different purposes.
        SafeERC20TransferFrom.safeTransferFrom(_token, _msgSender(), amount);

        // Requests a quote from the Uniswap V2-like contract.
        uint256 amountOut = query(amount, token, wNative);
        require(
            amountOut > 0,
            "UniswapDexERC20Wrapper: insufficient liquidity"
        );

        // Parses the payload of the message.
        SwapOptions memory swapOptions = abi.decode(payload, (SwapOptions));
        // Checks if the target swap price is still valid.
        require(
            amountOut >= swapOptions.minAmountOut,
            "UniswapDexERC20Wrapper: slippage exceeded"
        );

        // Verifies if the desired tokenOut is a native or wrapped asset.
        if (swapOptions.tokenOut == address(0)) {
            swap(amount, amountOut, token, wNative, address(this));
            IWrappedNativeToken(wNative).withdraw(amountOut);
            payable(originSenderAddress).transfer(amountOut);
        } else {
            swap(amount, amountOut, token, wNative, originSenderAddress);
        }
    }
}
