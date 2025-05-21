# EntryPoint Deployer

Simple helpers to deploy pre-compiled [ERC-4337](https://github.com/eth-infinitism/account-abstraction) contracts.

## Installation

```shell
forge install entrypoint=pyk/entrypoint-deployer@v0.7.0
```

## Usage

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { Test, console } from "forge-std/src/Test.sol";
import { EntryPointDeployer, IEntryPoint } from "entrypoint/Deployer.sol";

contract EntryPointTest is Test, EntryPointDeployer {
    IEntryPoint entryPoint;

    function setUp() external {
        entryPoint = deployEntryPoint();
    }
}
```

## Precompiles

| Name       | Version | Address                                                                                                               |
| ---------- | ------- | --------------------------------------------------------------------------------------------------------------------- |
| EntryPoint | v0.7.0  | [0x0000000071727De22E5E9d8BAf0edAc6f37da032](https://etherscan.io/address/0x0000000071727De22E5E9d8BAf0edAc6f37da032) |
