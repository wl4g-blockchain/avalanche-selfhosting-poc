// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {UniswapDexERC20Wrapper} from "../src/crosschaintoken/UniswapDexERC20Wrapper.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract DeployUniswapDexERC20Wrapper is Script {
    UniswapDexERC20Wrapper public dexWrapper;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // TODO:
        dexWrapper = new UniswapDexERC20Wrapper(address(0x0), address(0x0));

        vm.stopBroadcast();
    }
}
