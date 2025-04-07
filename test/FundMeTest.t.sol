//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    address alice = makeAddr("alice");
    uint256 constant SEND_VALUE = 10 ether; //

    function setUp() external {
        // Deploy the FundMe contract
        //fundMe = new FundMe();
        // Alternatively, you can use the DeployFundMe script to deploy the contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }
    
    function testMinimumDollarIsfive () public view {
        assertEq(fundMe.MINIMUM_USD(), 2e18, "The minimum dollar amount should be 2e18.");
    }

    function testOwnerIsMsgSender() public view{
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        address owner = msg.sender;
        assertEq(fundMe.i_owner(), owner, "The owner should be the address that deployed the contract.");
        //assertEq(fundMe.i_owner(), address(this), "The owner should be the address that deployed the contract.");
    }

    function testFundUpdatesFundDataStructure() public {
        vm.prank(alice);
        emit log_address(alice);
        vm.deal(alice, SEND_VALUE); // Give Alice 1 ether
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
        assertEq(amountFunded, SEND_VALUE, "The amount funded should be equal to the sent value.");
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

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(alice);
        emit log_address(alice);
        vm.deal(alice, SEND_VALUE); // Give Alice 1 ether
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, alice);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(alice);
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(alice);
        vm.deal(alice, SEND_VALUE); // Give Alice 1 ether
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testWithdrawFromASingleFunder() public funded {
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        
    }

    // function testFundFailsWIthoutEnoughETH() public {
    //     vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
    //     fundMe.fund();     // <- We send 0 value
    // } 
}