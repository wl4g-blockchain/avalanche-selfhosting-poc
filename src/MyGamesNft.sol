// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesNft is ERC721 {
    uint256 id;
    constructor() ERC721("Token", "MyGames") {}

    function mint(address to) public returns (uint256) {
        id += 1;
        _mint(to, id);
        return id;
    }
}
