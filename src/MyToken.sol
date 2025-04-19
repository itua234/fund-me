//SPDX-License-identifier: MIT

pragma solidity ^0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    string private _name = "MyToken";
    string private _symbol = "MTK";

    constructor(address recipient, address initialOwner)
        ERC20(_name, _symbol) 
        Ownable(initialOwner)
    {
        _mint(recipient, 100 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18; // Standard for most tokens
    }
}