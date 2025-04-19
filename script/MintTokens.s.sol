// SPDX-License-identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract MintTokens is Script {
    address myTokenAddress = vm.envAddress("TOKEN_ADDRESS");
    address recipient = vm.envAddress("MINT_RECIPIENT");
    uint256 amountToMint = uint256(vm.envUint("MINT_AMOUNT"));
    address ownerPrivateKey = vm.envAddress("OWNER_PRIVATE_KEY"); // Not ideal for real deployments

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        MyToken myToken = MyToken(payable(myTokenAddress));
        myToken.mint(recipient, amountToMint);
        vm.stopBroadcast();
    }
}