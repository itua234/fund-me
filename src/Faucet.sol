//SPDX-License-identifier: MIT

pragma solidity ^0.8.19;

contract Faucet {
    address public immutable i_owner;
    uint256 public dripAmount = 0.01 ether;
    mapping(address => uint256) public lastDrip;
    uint256 public cooldown = 1 hours; //3600

    constructor ()
    {
       i_owner = msg.sender;
    }

    receive () external payable {}

    fallback () external payable {}

    function requestFunds() external {
        require(block.timestamp - lastDrip[msg.sender] >= cooldown, "Cooldown not passed");
        require(address(this).balance >= dripAmount, "Faucet is empty");

        lastDrip[msg.sender] = block.timestamp;
        (
            bool callSuccess,
            //bytes memory dataReturned
        ) = payable(msg.sender).call{value: dripAmount}("");
        require(callSuccess, "Call failed: Unable to send funds to this address");
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, "Not owner");
        _;
    }

    function setDripAmount(uint256 amount) external onlyOwner {
        dripAmount = amount;
    }

    function setCoolDown(uint256 time) external {
        cooldown = time;
    }

    function withdraw()  public onlyOwner {
         (
            bool callSuccess,
            //bytes memory dataReturned
        ) = payable(i_owner).call{value: address(this).balance}("");
        require(callSuccess, "Call failed: Unable to send funds to this address");
    }
}