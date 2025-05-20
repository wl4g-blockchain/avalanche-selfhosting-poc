// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.25;

// import "forge-std/Script.sol";
// import "../src/CrossChainMessager.sol";

// /**
//  * Notice: Unable to test this Avalanche Cross ICM with Foundry, due to TeleporterMessenger depends on PreCompiled Contracts in the Avalanche EVM.
//  * see:https://github.com/ava-labs/icm-contracts/blob/57796c8d6c5fc7ac984b492b93233cf083ea8381/contracts/teleporter/TeleporterMessenger.sol#L674
//  * @title
//  * @author Mr.James W
//  * @notice
//  */
// contract InteractCrossChainMessager is Script {
//     function run() external {
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         CrossChainMessager messager = CrossChainMessager(
//             address(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf)
//         );

//         // bytes32 targetDomain = bytes32(
//         //     0xb74a02b2e99c3a9496b3d452b634ad724bb27ed67a5d4290569653b70dc24faa
//         // );

//         messager.sendTeleportMessage(
//             0xb74a02b2e99c3a9496b3d452b634ad724bb27ed67a5d4290569653b70dc24faa,
//             address(0xc8d9297aD06812a4644A84fA457eeAF23bFEa1a7),
//             "Hello, World!"
//         );

//         vm.stopBroadcast();
//     }
// }
