// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/MyGamesNft1.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract InteractMyGamesNft1 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyGamesNft1 nft = MyGamesNft1(address(0x00)); // Replace with your NFT contract address

        // Mint a new NFT to the deployer's address
        uint256 tokenId = nft.mint(address(0x112233));
        console.log("Minted NFT with token ID:", tokenId);

        vm.stopBroadcast();
    }
}
