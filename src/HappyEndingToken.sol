// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/Extensions/ERC20Burnable.sol";

contract HappyEndingToken is ERC20Burnable, Ownable
{
    address public marketingWallet;
    address public liquidityPool;

    mapping(address => bool) public isExcludedFromTax;

    constructor() ERC20("HappyEnding", "HPED") Ownable(_msgSender())
    {
        // Set total supply to 100 million tokens.
        uint256 totalSupply = 100_000_000 * 10 ** decimals();

        excludeFromTax(_msgSender(), true);
        excludeFromTax(address(this), true);
        excludeFromTax(address(0), true);

        _mint(_msgSender(), totalSupply);
    }

    function setLiquidityPool(address _liquidityPool) public onlyOwner
    {
        require(_liquidityPool != address(0), "Cannot set liquidity pool to address 0.");
        liquidityPool = _liquidityPool;
    }

    function excludeFromTax(address account, bool isExcluded) public onlyOwner
    {
        isExcludedFromTax[account] = isExcluded;
    }

    function _update(address from, address to, uint256 value) internal override {
        //TODO Implement fee structure
        super._update(from, to, value);
    }
}