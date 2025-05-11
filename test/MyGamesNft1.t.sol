// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {MyGamesNft1} from "../src/MyGamesNft1.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesNft1Test is Test {
    MyGamesNft1 nft;
    address deployer = address(0x123);
    address user1 = address(0x456);

    function setUp() public {
        // Set up the deployer's private key
        vm.prank(deployer);

        // Deploy the NFT contract.
        // TODO messager address
        // e.g: cat ~/.avalanche-cli/bin/icm-contracts/v1.0.0/TeleporterMessenger_Contract_Address_v1.0.0.txt
        nft = new MyGamesNft1(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);
    }

    function testMint() public {
        // Mint a new NFT to user1
        vm.prank(deployer);
        uint256 tokenId = nft.mint(user1);

        // Check that user1 owns the NFT
        address owner = nft.ownerOf(tokenId);
        assertEq(owner, user1, "User1 should own the minted NFT");
    }
}
