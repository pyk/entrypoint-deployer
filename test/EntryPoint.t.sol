// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { Test, console } from "forge-std/Test.sol";

import { EntryPointDeployer, IEntryPoint } from "../src/Deployer.sol";
import { IStakeManager } from "../src/interfaces/IStakeManager.sol";
import { INonceManager } from "../src/interfaces/INonceManager.sol";

contract EntryPointTest is Test, EntryPointDeployer {
    IEntryPoint entryPoint;

    address alice = makeAddr("alice");

    function setUp() external {
        entryPoint = deployEntryPoint();
    }

    // Test 1: ERC-165 supportsInterface
    // It should support IEntryPoint, IStakeManager, and INonceManager
    function testSupportsInterfaces() external view {
        bytes4 iEntryPointId = type(IEntryPoint).interfaceId;
        bytes4 iStakeManagerId = type(IStakeManager).interfaceId;
        bytes4 iNonceManagerId = type(INonceManager).interfaceId;
        bytes4 combinedEntryPointId = iEntryPointId ^ iStakeManagerId ^ iNonceManagerId;

        assertTrue(entryPoint.supportsInterface(combinedEntryPointId), "Should support combined IEntryPoint interface");
        assertTrue(entryPoint.supportsInterface(iEntryPointId), "Should support IEntryPoint specific functions");
        assertTrue(entryPoint.supportsInterface(iStakeManagerId), "Should support IStakeManager");
        assertTrue(entryPoint.supportsInterface(iNonceManagerId), "Should support INonceManager");

        // A known non-supported interface
        bytes4 randomInterfaceId = 0x12345678;
        assertFalse(entryPoint.supportsInterface(randomInterfaceId), "Should not support a random interface");
    }

    // Test 2: Initial deposit for an unknown address should be 0
    function testInitialDepositBalance() external view {
        address randomAddress = address(0xdeadbeef);
        assertEq(entryPoint.balanceOf(randomAddress), 0, "Initial deposit should be 0");
    }

    // Test 3: Initial stake info for an unknown address should be zeroed out
    function testInitialStakeInfo() external view {
        address randomAddress = address(0xfeedc0de);
        IStakeManager.DepositInfo memory info = entryPoint.getDepositInfo(randomAddress);
        assertEq(info.deposit, 0, "Initial info.deposit should be 0");
        assertFalse(info.staked, "Initial info.staked should be false");
        assertEq(info.stake, 0, "Initial info.stake should be 0");
        assertEq(info.unstakeDelaySec, 0, "Initial info.unstakeDelaySec should be 0");
        assertEq(info.withdrawTime, 0, "Initial info.withdrawTime should be 0");
    }

    // Test 4: Get nonce for an unknown address and key 0
    function testInitialNonce() external view {
        address randomAddress = address(0xcafe);
        uint192 key = 0;
        assertEq(entryPoint.getNonce(randomAddress, key), 0, "Initial nonce (key 0) should be 0");

        uint192 key2 = 123;
        uint256 expectedNonceForKey2 = uint256(key2) << 64;
        assertEq(entryPoint.getNonce(randomAddress, key2), expectedNonceForKey2, "Initial nonce for key2 incorrect");
    }

    // Test 5: Depositing ETH via depositTo()
    function testDepositTo() public {
        address depositor = address(this); // The test contract itself
        uint256 depositAmount = 1 ether;

        uint256 initialBalance = entryPoint.balanceOf(depositor);
        vm.deal(depositor, depositAmount); // Give test contract ETH to deposit

        entryPoint.depositTo{ value: depositAmount }(depositor);

        assertEq(entryPoint.balanceOf(depositor), initialBalance + depositAmount, "Deposit via depositTo failed");
    }

    // Test 6: Depositing ETH via receive() fallback
    function testReceiveFallbackDeposit() public {
        address depositor = address(this); // The test contract itself
        uint256 depositAmount = 0.5 ether;

        uint256 initialBalance = entryPoint.balanceOf(depositor);
        // Give test contract ETH to send
        vm.deal(depositor, depositAmount);

        // Send ETH directly to EntryPoint, should trigger receive() which calls depositTo(msg.sender)
        (bool success,) = payable(address(entryPoint)).call{ value: depositAmount }("");
        assertTrue(success, "Direct ETH transfer (receive) failed");

        assertEq(entryPoint.balanceOf(depositor), initialBalance + depositAmount, "Deposit via receive fallback failed");
    }

    // Test 7: getSenderAddress with empty initCode
    function testGetSenderAddressEmptyInitCodeReverts() public {
        // Simpler check for any revert is fine for basic validation if exact revert data is tricky.
        vm.expectRevert();
        entryPoint.getSenderAddress("");
    }
}
