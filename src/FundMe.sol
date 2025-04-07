//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//import {PriceConverter} from "./PriceConverter.sol";
library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        //Price of ETH in terms of USD
        // Chainlink returns price with 8 decimals, so scale it up to 18 decimals
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}

error FundMe_notOwner(string error);

contract FundMe {
    AggregatorV3Interface private s_priceFeed;
    address public immutable i_owner;
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 2e18;//minimun amount of dollars
    address[] public s_funders;
    mapping(address funder => uint256 amountFunded) public s_addressToAmountFunded;

    constructor (address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // @funds our contract based on the ETH/USD price feed
    // @minimum amount of dollars to fund the contract is 2e18 (2 USD)
    // @msg.value is the amount of ETH sent to the contract
    // @msg.sender is the address of the user that sent the ETH to the contract
    // @s_addressToAmountFunded is a mapping of the address of the user that sent the ETH to the contract and the amount of ETH sent to the contract
    // @s_funders is an array of the addresses of the users that sent ETH to the contract
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, 
            "Gas estimation failed. Error execution reverted, didn't send enough ETH."
        ); //1e18 = 1ETH = 1000000000000000000WEI
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
        return priceFeed.version();
    }

    modifier onlyOwner {
        if(msg.sender != i_owner){
            revert FundMe_notOwner("must be owner of the contract");
        }
        //require(msg.sender == i_owner, "must be owner");
        _;
    }

    // @sets the amount of ETH sent to the contract to 0 for each funder
    // @deletes the s_funders array
    // @ensure the contract has sufficient funds to withdraw
    // @sends the funds to the owner of the contract
    function withdraw() public onlyOwner {
        //address[] memory s_fundersCopy = s_funders;
        for(
            uint56 funderIndex = 0; 
            funderIndex < s_funders.length; 
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        delete s_funders;

        require(address(this).balance > 0, "Contract has no funds to withdraw");

        //uint256 contractBalance = address(this).balance;
        (
            bool callSuccess,
            //bytes memory dataReturned
        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed: Unable to send funds to the owner of the contract");
    }

    receive () external payable {
        fund();
    }

    fallback () external payable {
        fund();
    }

    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }
}