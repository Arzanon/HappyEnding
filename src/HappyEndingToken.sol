// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/Extensions/ERC20Burnable.sol";

contract HappyEnding is ERC20Burnable, Ownable
{
    address public marketingWallet;
    address public liquidityPool1;
    address public liquidityPool2;

    uint256 public sellTax;

    mapping(address => bool) public isExcludedFromTax;

    constructor() ERC20("Happy Ending", "HAPPY") Ownable(_msgSender())
    {
        // Set total supply to 525 million tokens
        uint256 totalSupply = 525_000_000 * 10 ** decimals();

        // Set sell tax to 0.1%
        sellTax = 10;

        // Set marketing wallet where tax is collected
        marketingWallet = 0xE35c58Ba9BaE2C12Bc1214eb2572E8c69ee30AC6;

        isExcludedFromTax[_msgSender()] = true;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[address(0)] = true;

        _mint(_msgSender(), totalSupply);
    }

    function setLiquidityPool1(address liquidityPool) public onlyOwner
    {
        liquidityPool1 = liquidityPool;
    }

    function setLiquidityPool2(address liquidityPool) public onlyOwner
    {
        liquidityPool2 = liquidityPool;
    }

    function _update(address from, address to, uint256 value) internal override
    {
        address lpAddress = address(0);

        if (!isExcludedFromTax[from] &&
            (to == liquidityPool1 || to == liquidityPool2))
        {
            lpAddress = to;
        }

        if (lpAddress != address(0))
        {
            uint256 fromBalance = balanceOf(from);
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }

            uint256 taxAmount = (value * sellTax) / 10_000;
            uint256 netAmount = value - taxAmount;

            super._update(from, marketingWallet, taxAmount);
            super._update(from, to, netAmount);
        }
        else
        {
            super._update(from, to, value);
        }
    }
}