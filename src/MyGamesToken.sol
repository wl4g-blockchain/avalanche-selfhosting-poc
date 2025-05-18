// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Token", "MG") {
        _mint(msg.sender, initialSupply);
    }
}
