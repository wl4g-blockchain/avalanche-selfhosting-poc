// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import {MyGamesNft} from "../src/MyGamesNft.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesNftTest is Test {
    MyGamesNft nft;
    address deployer = address(0x123);
    address nftAddress = address(0);
    address user1 = address(0x456);

    function setUp() public {
        // Set up the deployer's private key
        vm.prank(deployer);

        // Deploy the NFT contract.
        // TODO messager address
        // e.g: cat ~/.avalanche-cli/bin/icm-contracts/v1.0.0/TeleporterMessenger_Contract_Address_v1.0.0.txt
        nft = new MyGamesNft(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

        nftAddress = address(nft);
        console.log("Deployed the NFT address: %s", nftAddress);
    }

    function testMint() public {
        // Mint a new NFT to user1
        vm.prank(deployer);

        console.log("Minting NFT...");
        uint256 tokenId = nft.mint(user1);
        console.log("Minted NFT with token ID: %s", tokenId);

        // Check that user1 owns the NFT
        address owner = nft.ownerOf(tokenId);
        assertEq(owner, user1, "User1 should own the minted NFT");
    }

    // function testNotification() public {
    //     vm.prank(deployer);
    //     console.log("Notification Cross message...");
    //     nft.notification("<TODO other chain ID>", nftAddress);
    //     console.log("Notification Cross message completed");

    //     // TODO: Check the received message
    // }
}
