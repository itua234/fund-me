// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Faucet} from "../src/Faucet.sol";
import {console} from "forge-std/console.sol";  

contract DeployFaucet is Script {
    function run() external returns (Faucet) {
        vm.startBroadcast();
        
        Faucet faucet = new Faucet();
        console.log("Faucet contract deployed to:", address(faucet));
        
        vm.stopBroadcast();
        return faucet;
    }
}