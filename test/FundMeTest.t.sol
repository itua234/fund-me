//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() external {
        // Deploy the FundMe contract
        //fundMe = new FundMe();
        // Alternatively, you can use the DeployFundMe script to deploy the contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // Alternatively, you can use the following line to deploy the contract directly
        //fundMe = new FundMe(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF); // Chainlink ETH/USD price feed address on Goerli
        // Set up the test environment
        //vm.deal(address(this), 10 ether); // Give this contract 10 ether
    }
    
    function testMinimumDollarIsfive () public view {
        assertEq(fundMe.MINIMUM_USD(), 2e18, "The minimum dollar amount should be 2e18.");
    }

    function testOwnerIsMsgSender() public view{
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
        //assertEq(fundMe.i_owner(), address(this), "The owner should be the address that deployed the contract.");
    }

    function testFundUpdatesFundDataStructure() public {
        uint256 sendValue = 10 ether;
        fundMe.fund{value: sendValue}();
        assertEq(fundMe.addressToAmountFunded(msg.sender), sendValue, "The amount funded should be equal to the sent value.");
        // uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender);
        // assertEq(amountFunded, 10 ether);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log("Chain ID:", block.chainid);
        console.log("Version:", version);

        if (block.chainid == 11155111) {
            console.log(version);
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            console.log(version);
            assertEq(version, 6);
        }
    }       
}