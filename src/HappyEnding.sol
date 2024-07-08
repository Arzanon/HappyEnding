// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/Extensions/ERC20Burnable.sol";

contract HappyEndingToken is ERC20Burnable, Ownable
{
    constructor() ERC20("HappyEnding", "HPED") Ownable(_msgSender())
    {
        uint256 totalSupply = 100_000_000 * 10 ** decimals();
        
        _mint(_msgSender(), totalSupply);
    }
}