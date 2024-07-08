// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/Extensions/ERC20Burnable.sol";

contract HappyEndingToken is ERC20Burnable, Ownable
{
    address public marketingWallet;
    address public liquidityPool;

    uint256 public tax;

    mapping(address => bool) public isExcludedFromTax;

    constructor() ERC20("HappyEnding", "HAPPY") Ownable(_msgSender())
    {
        // Set total supply to 100 million tokens.
        uint256 totalSupply = 100_000_000 * 10 ** decimals();

        marketingWallet = address(0); //TODO set marketing wallet

        // Set tax to 0.1%
        tax = 10;

        isExcludedFromTax[_msgSender()] = true;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[address(0)] = true;

        _mint(_msgSender(), totalSupply);
    }

    function setLiquidityPool(address _liquidityPool) public onlyOwner
    {
        require(_liquidityPool != address(0), "Cannot set liquidity pool to address 0.");
        liquidityPool = _liquidityPool;
    }

    function _update(address from, address to, uint256 value) internal override
    {
        if (to == liquidityPool &&
            !isExcludedFromTax[from])
        {
            uint256 fromBalance = balanceOf(from);
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }

            uint256 taxAmount = (value * tax) / 10_000;
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