// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CrossChainMessager} from "../src/CrossChainMessager.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract DeployCrossChainMessager is Script {
    CrossChainMessager public messager;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Notice: Obtaining the messager address
        // e.g: cat ~/.avalanche-cli/bin/icm-contracts/v1.0.0/TeleporterMessenger_Contract_Address_v1.0.0.txt
        messager = new CrossChainMessager(
            0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf
        );

        vm.stopBroadcast();
    }
}
