// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY

forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL  --account defaultKey --sender 0x14dc79964da2c08b23698b3d3cc7ca32193d9955 --broadcast -vvvv

forge test --fork-url $SEPOLIA_RPC_URL
forge test --fork-url $MAINNET_RPC_URL

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
