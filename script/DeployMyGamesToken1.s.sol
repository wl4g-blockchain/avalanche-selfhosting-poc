// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyGamesToken1} from "../src/MyGamesToken1.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract DeployMyGamesToken1 is Script {
    MyGamesToken1 public token;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // TODO messager address
        // e.g: cat ~/.avalanche-cli/bin/icm-contracts/v1.0.0/TeleporterMessenger_Contract_Address_v1.0.0.txt
        token = new MyGamesToken1(
            0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf,
            1000000
        ); // Initial supply of 1,000,000 tokens

        vm.stopBroadcast();
    }
}
