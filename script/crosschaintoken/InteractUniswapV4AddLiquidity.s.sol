// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {IERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";

import {IPoolManager} from "@uniswap/v4-core/contracts@4.0.0/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts@4.0.0/types/PoolKey.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts@4.0.0/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/contracts@4.0.0/interfaces/IHooks.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts@4.0.0/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/contracts@4.0.0/libraries/TickMath.sol";

contract InitializePoolAndLiquidity is Script {
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolKey;

    function run() external {
        address poolManagerAddr = vm.envAddress("POOL_MANAGER_ADDRESS");
        address wNativeAddr = vm.envAddress("WNATIVE_ADDRESS");
        address testTokenAddr = vm.envAddress("TEST_TOKEN_ADDRESS");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IPoolManager poolManager = IPoolManager(poolManagerAddr);

        _initializePoolWithLiquidity(poolManager, testTokenAddr, wNativeAddr);

        vm.stopBroadcast();
    }

    function _initializePoolWithLiquidity(
        IPoolManager poolManager,
        address token0,
        address token1
    ) internal {
        // Ensure the tokens are sorted.
        if (token0 > token1) {
            (token0, token1) = (token1, token0);
        }

        console.log("Initializing pool for tokens:", token0, "and", token1);

        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: 3000, // 0.3%
            tickSpacing: 60,
            hooks: IHooks(address(0))
        });

        // 1. Initializing the swap pool (1:1 ratio)
        uint160 sqrtPriceX96 = TickMath.getSqrtPriceAtTick(0);
        poolManager.initialize(key, sqrtPriceX96, "");
        console.log("Pool initialized");

        // 2. Add the Liquidity.
        uint256 liquidityAmount = 1000e18;

        // Approve the tokens to PoolManager
        IERC20(token0).approve(address(poolManager), liquidityAmount);
        IERC20(token1).approve(address(poolManager), liquidityAmount);

        // Use a reasonable tick range (within the available range)
        int24 tickLower = -600; // Ensure in the beteewn minUsableTick and maxUsableTick range.
        int24 tickUpper = 600;

        IPoolManager.ModifyLiquidityParams memory params = IPoolManager
            .ModifyLiquidityParams({
                tickLower: tickLower,
                tickUpper: tickUpper,
                liquidityDelta: int128(int256(liquidityAmount)),
                salt: bytes32(0)
            });

        poolManager.modifyLiquidity(key, params, "");
        console.log("Liquidity added successfully");

        // Output the pool ID for verifyication.
        PoolId poolId = key.toId();
        console.log("Pool ID (bytes32):", vm.toString(PoolId.unwrap(poolId)));
    }
}
