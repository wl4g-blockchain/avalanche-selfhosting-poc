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
        address indexed originSenderAddress,
        uint256 messageSize
    );

    event ReceivedMessage(
        bytes32 indexed sourceBlockchainID,
        address indexed originSenderAddress,
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
    address public lastSwapOriginSenderAddress;
    uint256 public lastSwapAmount;
    string public lastSwapRemark;

    constructor(address router) {
        messenger = ITeleporterMessenger(router);
    }

    function sendERC20WithICM(
        bytes32 destinationBlockchainID,
        address destinationRouterAddress,
        address sourceTokenAddress,
        address destinationTokenAddress,
        uint256 amount,
        string calldata remark
    ) external {
        emit SendingMessage(
            destinationBlockchainID,
            destinationRouterAddress,
            amount,
            remark
        );

        // Lock tokens (Notice: Must be approved before calling this function)
        IERC20(sourceTokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // Wrap to bytes message
        bytes memory message = abi.encode(
            destinationTokenAddress,
            msg.sender,
            amount,
            remark
        );

        // Send via ICM
        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: destinationBlockchainID,
                destinationAddress: destinationRouterAddress,
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
            destinationRouterAddress,
            amount,
            remark
        );
    }

    function receiveTeleporterMessage(
        bytes32 sourceBlockchainID,
        address originSenderAddress,
        bytes calldata message
    ) external {
        // Only the Interchain Messaging receiver can deliver a message.
        require(
            msg.sender == address(messenger),
            "ReceiverOnSubnet: unauthorized TeleporterMessenger"
        );

        emit ReceivingMessage(
            sourceBlockchainID,
            originSenderAddress,
            message.length
        );

        // Store the message.
        lastSwapSourceBlockchainID = sourceBlockchainID;
        lastSwapOriginSenderAddress = originSenderAddress;
        (
            address destinationTokenAddress,
            address to,
            uint256 amount,
            string memory remark
        ) = abi.decode(message, (address, address, uint256, string));
        lastSwapAmount = amount;
        lastSwapRemark = remark;

        emit ReceivedMessage(
            lastSwapSourceBlockchainID,
            lastSwapOriginSenderAddress,
            amount,
            remark
        );

        // Mint token to user
        _mintToken(destinationTokenAddress, to, amount, remark);
    }

    function _mintToken(
        address destinationTokenAddress,
        address to,
        uint256 amount,
        string memory remark
    ) internal {
        // Approve token to spender.
        // SafeERC20.forceApprove(
        //     IERC20(destinationTokenAddress),
        //     address(this),
        //     amount
        // );
        // IERC20(destinationTokenAddress).approve(address(this), amount);

        // Transfer token to source user address
        IERC20(destinationTokenAddress).transfer(to, amount);
        emit TokensMinted(destinationTokenAddress, to, amount, remark);
    }
}
