// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe  is Script{
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();

        FundMe fundMe = new FundMe(ethUsdPriceFeed); // Goerli ETH/USD price feed address
        console.log("FundMe contract deployed to:", address(fundMe));

        vm.stopBroadcast();
        return fundMe;
    }
}