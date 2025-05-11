## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
# Avalanche Devnet deploy generated RPC info such as:
$ export RPC_URL="http://127.0.0.1:60172/ext/bc/Yt9d8RRW9JcoqfvyefqJJMX14HawtBc28J9CQspQKPkdonp1y/rpc"

$ forge script script/DeployMyGamesNft1.s.sol:DeployMyGamesNft1 --rpc-url ${RPC_URL} --broadcast -vvvv
# [⠊] Compiling...
# No files changed, compilation skipped
# Traces:
#   [2455715] DeployMyGamesNft1::run()
#     ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
#     │   └─ ← [Return] <env var value>
#     ├─ [0] VM::startBroadcast(<pk>)
#     │   └─ ← [Return] 
#     ├─ [2410555] → new MyGamesNft1@0x5CC00A3b7a53FECD43107b36D305E4aC73EAcfB5
#     │   └─ ← [Return] 11700 bytes of code
#     ├─ [0] VM::stopBroadcast()
#     │   └─ ← [Return] 
#     └─ ← [Stop] 
# Script ran successfully.
# ## Setting up 1 EVM.
# ==========================
# Simulated On-chain Traces:
#   [2410555] → new MyGamesNft1@0x5CC00A3b7a53FECD43107b36D305E4aC73EAcfB5
#     └─ ← [Return] 11700 bytes of code
# ==========================
# Chain 43113002
# Estimated gas price: 50.000000001 gwei
# Estimated total gas used for script: 3459808
# Estimated amount required: 0.172990400003459808 ETH
# ==========================
# ##### 43113002
# ✅  [Success] Hash: 0xe5c4b43c29e9817b36d4206e47dc3f1554d853d55524c1b285f172347a3bcb30
# Contract Address: 0x5CC00A3b7a53FECD43107b36D305E4aC73EAcfB5
# Block: 9
# Paid: 0.066534775002661391 ETH (2661391 gas * 25.000000001 gwei)
# ✅ Sequence #1 on 43113002 | Total Paid: 0.066534775002661391 ETH (2661391 gas * avg 25.000000001 gwei)
# ==========================
# ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
# Transactions saved to: /Users/jw/Documents/default-workspace/blockchain-projects/3-avalanche-infra-projects/avalanche-selfhosting-examples/broadcast/DeployMyGamesNft1.s.sol/43113002/run-latest.json
# Sensitive values saved to: /Users/jw/Documents/default-workspace/blockchain-projects/3-avalanche-infra-projects/avalanche-selfhosting-examples/cache/DeployMyGamesNft1.s.sol/43113002/run-latest.json

$ forge script script/DeployMyGamesToken1.s.sol:DeployMyGamesToken1 --rpc-url ${RPC_URL} --broadcast -vvvv
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
