// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {CrossChainMessager} from "./CrossChainMessager.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesNft1 is ERC721, CrossChainMessager {
    uint256 id;
    constructor(
        address messagerAddress
    ) ERC721("Token", "MyGamesNft1") CrossChainMessager(messagerAddress) {}

    function mint(address to) public returns (uint256) {
        id += 1;
        _mint(to, id);

        string memory mintMsg = string(
            abi.encodePacked(
                "Hello, minted MyGamesNft1 is ",
                Strings.toString(id)
            )
        );
        this.sendTeleportMessage(
            0xb72b346fcc8c1ebb30087e2d2841eac9302dde8fc5969dcc84fad6db5ebd261d,
            // TODO destinationAddress
            0x0000000000000000000000000000000000000000,
            mintMsg
        );

        return id;
    }
}
