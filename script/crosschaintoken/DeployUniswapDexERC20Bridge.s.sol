// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {IERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";

import {WrappedNativeToken} from "@avalanche-icm/contracts@1.0.8/ictt/WrappedNativeToken.sol";

import {IPoolManager} from "@uniswap/v4-core/contracts@4.0.0/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/contracts@4.0.0/interfaces/IHooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts@4.0.0/PoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts@4.0.0/types/PoolKey.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts@4.0.0/types/Currency.sol";
import {TickMath} from "@uniswap/v4-core/contracts@4.0.0/libraries/TickMath.sol";

import {UniswapDexERC20Bridge} from "../../src/crosschaintoken/UniswapDexERC20Bridge.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract DeployUniswapDexERC20Bridge is Script {
    using CurrencyLibrary for Currency;

    PoolManager public poolManager;
    UniswapDexERC20Bridge public bridge;
    WrappedNativeToken public wNative;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy the Wrapped Native Token
        console.log("Deploying Wrapped Native Token...");
        string memory chainName = vm.envOr("CHAIN_NAME", string("MyGames1"));
        wNative = new WrappedNativeToken(chainName);
        console.log("Wrapped Native Token deployed at:", address(wNative));

        // 2. Deploy the PoolManager
        console.log("Deploying PoolManager...");
        poolManager = new PoolManager(500000); // 500k gas limit
        console.log("PoolManager deployed at:", address(poolManager));

        // 3. Deploy the Bridge
        console.log("Deploying UniswapDexERC20Bridge...");
        bridge = new UniswapDexERC20Bridge(
            address(wNative),
            address(poolManager)
        );
        console.log("Bridge deployed at:", address(bridge));

        vm.stopBroadcast();

        // 4. Print deployment info
        _logDeploymentInfo();
    }

    function _logDeploymentInfo() internal view {
        console.log("\n=== UniswapDexERC20Bridge Deployment Summary ===");
        console.log("Chain Name:", wNative.name());
        console.log("Wrapped Native Token:", address(wNative));
        console.log("PoolManager:", address(poolManager));
        console.log("UniswapDexERC20Bridge:", address(bridge));
        console.log("==========================\n");
    }
}
