// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {CrossChainMessager} from "./CrossChainMessager.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesToken is ERC20, CrossChainMessager {
    constructor(
        address messagerAddress,
        uint256 initialSupply
    ) ERC20("Token", "MyGames1") CrossChainMessager(messagerAddress) {
        _mint(msg.sender, initialSupply);
    }
}
