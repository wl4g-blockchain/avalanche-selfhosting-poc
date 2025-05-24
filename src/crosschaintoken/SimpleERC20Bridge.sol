// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts@5.0.2/token/ERC20/utils/SafeERC20.sol";

import {ITeleporterMessenger, TeleporterMessageInput, TeleporterFeeInfo} from "@avalanche-icm/contracts@1.0.8/teleporter/ITeleporterMessenger.sol";
import {ITeleporterReceiver} from "@avalanche-icm/contracts@1.0.8/teleporter/ITeleporterReceiver.sol";

contract SimpleERC20Bridge is ITeleporterReceiver {
    event SendingMessage(
        bytes32 indexed destinationBlockchainID,
        address indexed destinationAddress,
        uint256 amount,
        string remark
    );

    event SentMessage(
        bytes32 indexed destinationBlockchainID,
        address indexed destinationAddress,
        uint256 amount,
        string remark
    );

    event ReceivingMessage(
        bytes32 indexed sourceBlockchainID,
        address indexed sourceAddress,
        uint256 messageSize
    );

    event ReceivedMessage(
        bytes32 indexed sourceBlockchainID,
        address indexed sourceAddress,
        uint256 amount,
        string remark
    );

    event TokensMinted(
        address indexed token,
        address indexed to,
        uint256 amount,
        string remark
    );

    using SafeERC20 for IERC20;
    address public immutable teleporterRouter;
    ITeleporterMessenger public messenger;

    bytes32 public lastSwapSourceBlockchainID;
    address public lastSwapSourceAddress;
    uint256 public lastSwapAmount;
    string public lastSwapRemark;

    constructor(address router) {
        messenger = ITeleporterMessenger(router);
    }

    function sendERC20WithICM(
        bytes32 destinationBlockchainID,
        address destinationAddress,
        address erc20TokenAddress,
        uint256 amount,
        string calldata remark
    ) external {
        emit SendingMessage(
            destinationBlockchainID,
            destinationAddress,
            amount,
            remark
        );

        // Lock tokens
        IERC20(erc20TokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Wrap to bytes message
        bytes memory message = abi.encode(
            erc20TokenAddress,
            msg.sender,
            amount,
            remark
        );

        // Send via ICM
        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: destinationBlockchainID,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({
                    feeTokenAddress: address(0),
                    amount: 0
                }),
                requiredGasLimit: 200000,
                allowedRelayerAddresses: new address[](0),
                message: message
            })
        );

        emit SentMessage(
            destinationBlockchainID,
            destinationAddress,
            amount,
            remark
        );
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
        lastSwapSourceBlockchainID = sourceBlockchainID;
        lastSwapSourceAddress = sourceAddress;
        (address token, address to, uint256 amount, string memory remark) = abi
            .decode(message, (address, address, uint256, string));

        emit ReceivedMessage(
            lastSwapSourceBlockchainID,
            lastSwapSourceAddress,
            amount,
            remark
        );

        // Mint token to user
        _mintToken(token, to, amount, remark);
    }

    function _mintToken(
        address token,
        address to,
        uint256 amount,
        string memory remark
    ) internal {
        // This could be a wrapped version or native mint
        // In production, you should use a mapping of canonical tokens
        IERC20(token).transfer(to, amount);
        emit TokensMinted(token, to, amount, remark);
    }
}
