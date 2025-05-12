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

        nft = new MyGamesNft();

        vm.stopBroadcast();
    }
}
