// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyGamesToken} from "../src/MyGamesToken.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract DeployMyGamesToken is Script {
    uint256 initialSupply = 10000000 * 10 ** 18; // Initial supply of 10,000,000 * 10^18 tokens
    MyGamesToken public token;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        token = new MyGamesToken(initialSupply);

        vm.stopBroadcast();
    }
}
