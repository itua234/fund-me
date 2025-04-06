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

error notOwner(string error);

contract FundMe {
    AggregatorV3Interface private s_priceFeed;
    address public immutable i_owner;
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 2e18;//minimun amount of dollars
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    constructor (address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // @funds our contract based on the ETH/USD price feed
    // @minimum amount of dollars to fund the contract is 2e18 (2 USD)
    // @msg.value is the amount of ETH sent to the contract
    // @msg.sender is the address of the user that sent the ETH to the contract
    // @addressToAmountFunded is a mapping of the address of the user that sent the ETH to the contract and the amount of ETH sent to the contract
    // @funders is an array of the addresses of the users that sent ETH to the contract
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, 
            "Gas estimation failed. Error execution reverted, didn't send enough ETH."
        ); //1e18 = 1ETH = 1000000000000000000WEI
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
        return priceFeed.version();
    }

    modifier onlyOwner {
        if(msg.sender == i_owner){
            revert notOwner("must be owner of the contract");
        }
        //require(msg.sender == i_owner, "must be owner");
        _;
    }

    function withdraw() public onlyOwner {
        for(uint56 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        delete funders;

        (
            bool callSuccess,
            //bytes memory dataReturned
        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    receive () external payable {
        fund();
    }

    fallback () external payable {
        fund();
    }
}