// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/MyGamesNft.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract DeployMyGamesNft is Script {
    MyGamesNft nft;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // TODO messager address
        // e.g: cat ~/.avalanche-cli/bin/icm-contracts/v1.0.0/TeleporterMessenger_Contract_Address_v1.0.0.txt
        nft = new MyGamesNft(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

        vm.stopBroadcast();
    }
}
