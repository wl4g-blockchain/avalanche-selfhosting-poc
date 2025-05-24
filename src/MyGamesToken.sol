// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyGamesToken", "MGT") {
        _mint(msg.sender, initialSupply);
    }
}
