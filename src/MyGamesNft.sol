// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts@5.0.2/token/ERC721/ERC721.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesNft is ERC721 {
    uint256 public id;

    constructor() ERC721("MyGamesNft", "MGN") {}

    function mint(address to) public returns (uint256) {
        id += 1;
        _mint(to, id);
        return id;
    }
}
