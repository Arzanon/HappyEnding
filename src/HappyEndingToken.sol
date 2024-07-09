// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/Extensions/ERC20Burnable.sol";

contract HappyEndingToken is ERC20Burnable, Ownable
{
    address public marketingWallet;
    address public liquidityPool;

    uint256 public sellTax;

    mapping(address => bool) public isExcludedFromTax;

    constructor() ERC20("HappyEnding", "HAPPY") Ownable(_msgSender())
    {
        // Set total supply to 525 million tokens.
        uint256 totalSupply = 525_000_000 * 10 ** decimals();

        // Set sell tax to 0.1%
        sellTax = 10;

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

    function setMarketingWallet(address _marketingWallet) public onlyOwner
    {
        require(_marketingWallet != address(0), "Cannot set marketing wallet to address 0.");
        marketingWallet = _marketingWallet;
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