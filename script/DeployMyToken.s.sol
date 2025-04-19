// SPDX-License-identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract DeployMyToken is Script {
    //address recipient = vm.envAddress("RECIPIENT"); // Get recipient from environment variable
    //address initialOwner = vm.envAddress("OWNER");   // Get owner from environment variable
    address recipient = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
    address initialOwner = 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f;
    
    function run() public {
        vm.startBroadcast();
        new MyToken(recipient, initialOwner);
        vm.stopBroadcast();
    }
}
// git submodule add https://github.com/OpenZeppelin/openzeppelin-contracts lib/openzeppelin-contracts
// cast send/call <CONTRACT_ADDRESS> "mint(address,uint256)" <RECIPIENT_ADDRESS> <AMOUNT_TO_MINT> --rpc-url <YOUR_RPC_URL>
// cast send 0x700b6A60ce7EaaEA56F065753d8dcB9653dbAD35 "mint(address,uint256)" 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 25000000000000000000000 --rpc-url $RPC_URL --private-key dbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97 --broadcast
//forge script script/DeployMyToken.s.sol:DeployMyToken --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast