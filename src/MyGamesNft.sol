// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {CrossChainMessager} from "./CrossChainMessager.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract MyGamesNft is ERC721, CrossChainMessager {
    uint256 id;
    constructor(
        address messagerAddress
    ) ERC721("Token", "MyGamesNft") CrossChainMessager(messagerAddress) {}

    function mint(address to) public returns (uint256) {
        id += 1;
        _mint(to, id);
        return id;
    }

    function notification(
        bytes32 destinationBlockchainID,
        address destinationAddress
    ) public returns (uint256) {
        string memory message = string(
            abi.encodePacked(
                "Hello, MyGamesNft minted current ID is ",
                Strings.toString(id)
            )
        );
        this.sendTeleportMessage(
            destinationBlockchainID,
            destinationAddress,
            message
        );

        return id;
    }
}
