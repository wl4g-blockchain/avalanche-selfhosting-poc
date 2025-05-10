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
$ forge script script/DeployMyGamesNft.s.sol:DeployMyGamesNft --rpc-url ${RPC_URL} --broadcast -vvvv
$ forge script script/DeployMyGamesToken.s.sol:DeployMyGamesToken --rpc-url ${RPC_URL} --broadcast -vvvv
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
