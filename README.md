# Seft-hosting Avlanche L1 Chains PoC

**The [Avalanche](https://subnets.avax.network/validators/dashboard/) Self-Hosting L1 Deploy + Cross Chain Messaging / Token Transfer PoC.**

## Features

- [x] Deploy Multi Self-Hosting Avalanche L1 Chains on Container.
- [x] Deploy the [`MyGamesNft`](./src/MyGamesNft.sol) contract to Self-Hosting Avalanche L1 Chain `MyGames1` or `MyGames2` and Mint Transfer Verification.
- [x] Deploy the [`MyGamesToken`](./src/MyGamesToken.sol) contract to Self-Hosting Avalanche L1 Chain `MyGames1` or `MyGames2` and Transfer Verification.
- [x] Tell messages Cross-chain to Self-hosting Avalanche L1 `MyGames2` from `MyGames1` based on the [`AWM/ICM/Teleporter`](https://github.com/ava-labs/icm-contracts/tree/main/contracts/teleporter).
- [ ] Transfer the token [`MyGamesToken`](./src/MyGamesToken.sol) across chains to the Self-hosting Avalanche L1 `MyGames2` from `MyGames1` based on [`ICTT`](https://github.com/ava-labs/icm-contracts/tree/v1.0.8/contracts/ictt) bridge.

## Quick Start

- [Case 1: Deployment of Avalanche L1 Chains and Mint NFT and Transfer Token and Verifyication](./docs/1.Deploy-L1-and-Mint-NFT-and-Token-Transfer.md)
