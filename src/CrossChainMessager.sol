// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ITeleporterMessenger, TeleporterMessageInput, TeleporterFeeInfo} from "icm-contracts/teleporter/ITeleporterMessenger.sol";
import {ITeleporterReceiver} from "icm-contracts/teleporter/ITeleporterReceiver.sol";

/**
 * @title
 * @author Mr.James W
 * @notice
 */
contract CrossChainMessager is ITeleporterReceiver {
    event SendingMessage(
        bytes32 indexed destinationBlockchainID,
        address indexed destinationAddress,
        string message
    );

    event SentMessage(
        bytes32 indexed destinationBlockchainID,
        address indexed destinationAddress,
        string message
    );

    event ReceivingMessage(
        bytes32 indexed sourceBlockchainID,
        address indexed sourceAddress,
        uint256 messageSize
    );

    event ReceivedMessage(
        bytes32 indexed sourceBlockchainID,
        address indexed sourceAddress,
        string message
    );

    ITeleporterMessenger public messenger;

    bytes32 public lastSourceBlockchainID;
    address public lastSourceAddress;
    string public lastMessage;

    constructor(address messagerAddress) {
        messenger = ITeleporterMessenger(messagerAddress);
    }

    /**
     * @dev Sends a message to another chain.
     */
    function sendTeleportMessage(
        bytes32 destinationBlockchainID,
        address destinationAddress,
        string calldata message
    ) external {
        emit SendingMessage(
            destinationBlockchainID,
            destinationAddress,
            message
        );

        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: destinationBlockchainID,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({
                    feeTokenAddress: address(0),
                    amount: 0
                }),
                requiredGasLimit: 100000,
                allowedRelayerAddresses: new address[](0),
                message: abi.encode(message)
            })
        );

        emit SentMessage(destinationBlockchainID, destinationAddress, message);
    }

    function receiveTeleporterMessage(
        bytes32 sourceBlockchainID,
        address sourceAddress,
        bytes calldata message
    ) external {
        // Only the Interchain Messaging receiver can deliver a message.
        require(
            msg.sender == address(messenger),
            "ReceiverOnSubnet: unauthorized TeleporterMessenger"
        );

        emit ReceivingMessage(
            sourceBlockchainID,
            sourceAddress,
            message.length
        );

        // Store the message.
        lastSourceBlockchainID = sourceBlockchainID;
        lastSourceAddress = sourceAddress;
        lastMessage = abi.decode(message, (string));

        emit ReceivedMessage(
            lastSourceBlockchainID,
            lastSourceAddress,
            lastMessage
        );
    }
}
