// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import {ITeleporterMessenger, TeleporterMessageInput, TeleporterFeeInfo} from "@avalanche-icm/contracts@1.0.8/teleporter/ITeleporterMessenger.sol";
// import {ITeleporterReceiver} from "@avalanche-icm/contracts@1.0.8/teleporter/ITeleporterReceiver.sol";

// contract ICMERC20Wrapper is ITeleporterReceiver {
//     event TokensMinted(
//         address indexed token,
//         address indexed to,
//         uint256 amount
//     );

//     using SafeERC20 for IERC20;
//     address public immutable teleporterRouter;
//     bytes32 public immutable destinationChainID;
//     address public immutable destinationTokenReceiver;

//     constructor(
//         address _teleporterRouter,
//         bytes32 _destinationChainID,
//         address _destinationTokenReceiver
//     ) {
//         teleporterRouter = _teleporterRouter;
//         destinationChainID = _destinationChainID;
//         destinationTokenReceiver = _destinationTokenReceiver;
//     }

//     function depositERC20(address tokenAddress, uint256 amount) external {
//         // Lock tokens
//         IERC20(tokenAddress).safeTransferFrom(
//             msg.sender,
//             address(this),
//             amount
//         );

//         // Prepare message
//         bytes memory message = abi.encode(tokenAddress, msg.sender, amount);

//         // Send via ICM
//         ITeleporterMessenger(teleporterRouter).sendCrossChainMessage(
//             ITeleporterMessenger.TeleporterMessageInput({
//                 destinationBlockchainID: destinationChainID,
//                 destinationAddress: destinationTokenReceiver,
//                 feeInfo: ITeleporterMessenger.TeleporterFeeInfo({
//                     feeTokenAddress: address(0),
//                     amount: 0
//                 }),
//                 requiredGasLimit: 200000,
//                 allowedRelayerAddresses: new address[](0),
//                 message: message
//             })
//         );
//     }

//     function receiveTeleporterMessage(
//         bytes calldata message
//     ) external override {
//         require(msg.sender == owner, "Only owner can receive");

//         (address token, address to, uint256 amount) = abi.decode(
//             message,
//             (address, address, uint256)
//         );

//         // Mint token to user
//         _mintToken(token, to, amount);
//     }

//     function _mintToken(address token, address to, uint256 amount) internal {
//         // This could be a wrapped version or native mint
//         // In production, you should use a mapping of canonical tokens
//         ERC20(token).mint(to, amount);
//         emit TokensMinted(token, to, amount);
//     }
// }
