//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Faucet} from "../src/Faucet.sol";
import {DeployFaucet} from "../script/DeployFaucet.s.sol";

contract FaucetTest is Test {
    Faucet public faucet;
    address alice = makeAddr("alice");
    uint256 constant SEND_VALUE = 1 ether; //

    function setUp() external {
        // Deploy the Faucet contract
        faucet = new Faucet();
        vm.deal(alice, SEND_VALUE); // Give Alice 1 ether
    }

    function testRequestFunds() public {
        vm.prank(alice);
        emit log_address(alice);
       
        faucet.requestFunds();
        assertGt(address(this).balance, 0, "The owner balance must be higher that the requested amount.");
    }
}