// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {SimpleERC20Bridge} from "../../src/crosschaintoken/SimpleERC20Bridge.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract DeploySimpleERC20Bridge is Script {
    SimpleERC20Bridge public bridge;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address teleporterRouter = vm.envOr(
            "TELEPORTER_ROUTER_ADDRESS",
            // Notice: The default address is local deployed by avalanche-cli.
            address(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf)
        );
        bridge = new SimpleERC20Bridge(teleporterRouter);

        vm.stopBroadcast();
    }
}
