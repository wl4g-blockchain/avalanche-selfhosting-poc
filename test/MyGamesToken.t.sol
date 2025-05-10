// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyGamesToken} from "../src/MyGamesToken.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyTokenTest is Test {
    MyGamesToken token;
    address deployer = address(0x123);
    address user1 = address(0x456);
    address user2 = address(0x789);

    function setUp() public {
        // Set up the deployer's private key
        vm.prank(deployer);

        // Deploy the token contract with an initial supply of 1,000,000 tokens
        token = new MyGamesToken(1000000);
    }

    function testInitialSupply() public {
        // Check that the deployer has the initial supply
        uint256 deployerBalance = token.balanceOf(deployer);
        assertEq(
            deployerBalance,
            1000000,
            "Deployer should have the initial supply"
        );
    }

    function testTransfer() public {
        // Transfer 100 tokens from deployer to user1
        vm.prank(deployer);
        token.transfer(user1, 100);
        vm.prank(deployer);
        token.transfer(user1, 100);

        // Check balances after transfer
        uint256 deployerBalance = token.balanceOf(deployer);
        uint256 user1Balance = token.balanceOf(user1);

        assertEq(
            deployerBalance,
            1000000 - 200,
            "Deployer balance should decrease by 200"
        );
        assertEq(user1Balance, 200, "User1 should receive 200 tokens");
    }
}
