// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/HappyEndingToken.sol";

contract HappyEndingTest is Test
{
    HappyEnding happyEnding;

    address contractCreator;
    address liquidityPool1;
    address liquidityPool2;
    address marketingWallet;

    function setUp() public {
        contractCreator = address(0x099);
        liquidityPool1 = address(0x098);
        liquidityPool2 = address(0x097);
        marketingWallet = address(0x20a29C14384139faE8870D06D1aC2Ea9d218feC9);

        vm.prank(contractCreator);
        happyEnding = new HappyEnding();
    }

    //#region TEST owner set address functions

    function testFail_setLiquidityPool_CannotSetAddressToZero() public
    {
        vm.prank(contractCreator);
        happyEnding.setLiquidityPool(address(0), true);
    }

    function test_setLiquidityPool_SetAddresses() public
    {
        vm.startPrank(contractCreator);
        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.setLiquidityPool(liquidityPool2, false);
        assertTrue(happyEnding.liquidityPools(liquidityPool1) == true);
        assertTrue(happyEnding.liquidityPools(liquidityPool2) == false);
        assertTrue(happyEnding.liquidityPools(address(0x1)) == false);
        vm.stopPrank();
    }

    //#endregion

    //#region TEST standard callers of the _update method, ensure behaviour is unchanged

    function test_IsMintedNotTaxed() public view
    {
        assertTrue(happyEnding.totalSupply() == happyEnding.balanceOf(contractCreator));
    }

    function test_IsBurnedNotTaxed() public
    {
        uint256 totalSupply = happyEnding.totalSupply();
        uint256 amountToBurn = 1337_420_69;
        
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.burn(amountToBurn);

        assertTrue(happyEnding.totalSupply() == totalSupply - amountToBurn);
        assertTrue(happyEnding.balanceOf(contractCreator) == totalSupply - amountToBurn);

        vm.stopPrank();
    }

    function test_transfer_ZeroTransfer() public
    {
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);

        uint256 totalSupply = happyEnding.totalSupply();

        happyEnding.transfer(address(0x1), 0);

        assertTrue(happyEnding.balanceOf(marketingWallet) == 0);
        assertTrue(happyEnding.balanceOf(address(0x1)) == 0);
        assertTrue(happyEnding.balanceOf(contractCreator) == totalSupply);

        vm.stopPrank();
    }

    function test_transfer_OneTransfer() public
    {
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);

        uint256 totalSupply = happyEnding.totalSupply();

        happyEnding.transfer(address(0x1), 1);

        assertTrue(happyEnding.balanceOf(marketingWallet) == 0);
        assertTrue(happyEnding.balanceOf(address(0x1)) == 1);
        assertTrue(happyEnding.balanceOf(contractCreator) == totalSupply - 1);

        vm.stopPrank();
    }

    function testFail_transfer_MaxTransfer() public
    {
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);

        happyEnding.transfer(address(0x1), type(uint256).max);

        vm.stopPrank();
    }

    function testFail_transfer_MaxMinusOneTransfer() public
    {
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);

        happyEnding.transfer(address(0x1), type(uint256).max - 1);

        vm.stopPrank();
    }

    function test_transfer_TotalSupplyTransfer() public
    {
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);

        uint256 totalSupply = happyEnding.totalSupply();

        happyEnding.transfer(address(0x1), totalSupply);

        assertTrue(happyEnding.balanceOf(marketingWallet) == 0);
        assertTrue(happyEnding.balanceOf(address(0x1)) == happyEnding.totalSupply());
        assertTrue(happyEnding.balanceOf(contractCreator) == 0);

        vm.stopPrank();
    }

    //#endregion

    //#region TEST taxed transfers

    function test_transfer_TaxedZeroTransfer() public
    {
        uint256 totalSupply = happyEnding.totalSupply();

        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.transfer(address(0x1), totalSupply);

        vm.stopPrank();
        vm.startPrank(address(0x1));

        happyEnding.transfer(liquidityPool1, 0);

        assertTrue(happyEnding.balanceOf(marketingWallet) == 0);
        assertTrue(happyEnding.balanceOf(liquidityPool1) == 0);
        assertTrue(happyEnding.balanceOf(address(0x1)) == totalSupply);

        vm.stopPrank();
    }

    function test_transfer_TaxedOneTransfer() public
    {
        uint256 totalSupply = happyEnding.totalSupply();

        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.transfer(address(0x1), totalSupply);

        vm.stopPrank();
        vm.startPrank(address(0x1));

        happyEnding.transfer(liquidityPool1, 1);

        assertTrue(happyEnding.balanceOf(marketingWallet) == 0);
        assertTrue(happyEnding.balanceOf(liquidityPool1) == 1);
        assertTrue(happyEnding.balanceOf(address(0x1)) == totalSupply - 1);

        vm.stopPrank();
    }

    function testFail_transfer_TaxedMaxTransfer() public
    {
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.transfer(address(0x1), happyEnding.totalSupply());

        vm.stopPrank();
        vm.startPrank(address(0x1));

        happyEnding.transfer(liquidityPool1, type(uint256).max);

        vm.stopPrank();
    }

    function testFail_transfer_TaxedMaxMinusOneTransfer() public
    {
        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.transfer(address(0x1), happyEnding.totalSupply());

        vm.stopPrank();
        vm.startPrank(address(0x1));

        happyEnding.transfer(liquidityPool1, type(uint256).max - 1);

        vm.stopPrank();
    }

    function test_transfer_TaxedTotalSupplyTransfer() public
    {
        uint256 totalSupply = happyEnding.totalSupply();

        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.transfer(address(0x1), totalSupply);

        vm.stopPrank();
        vm.startPrank(address(0x1));

        happyEnding.transfer(liquidityPool1, totalSupply);
        uint256 expectedTax = (totalSupply * happyEnding.sellTax()) / 10_000;
        uint256 expectedLeftover = totalSupply - expectedTax;

        assertTrue(happyEnding.balanceOf(marketingWallet) == expectedTax);
        assertTrue(happyEnding.balanceOf(address(0x1)) == 0);
        assertTrue(happyEnding.balanceOf(liquidityPool1) == expectedLeftover);

        vm.stopPrank();
    }

    function test_transfer_TaxedNormalTransferOnePool() public
    {
        uint256 totalSupply = happyEnding.totalSupply();

        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.setLiquidityPool(liquidityPool2, false);
        happyEnding.transfer(address(0x1), totalSupply);

        vm.stopPrank();
        vm.startPrank(address(0x1));

        happyEnding.transfer(liquidityPool1, 1337_420_69);
        happyEnding.transfer(liquidityPool2, 1337_420_69);
        uint256 expectedTax = 133742;
        uint256 expectedLeftover = 133608327;

        assertTrue(happyEnding.balanceOf(marketingWallet) == expectedTax);
        assertTrue(happyEnding.balanceOf(address(0x1)) == totalSupply - (1337_420_69 * 2));
        assertTrue(happyEnding.balanceOf(liquidityPool1) == expectedLeftover);
        assertTrue(happyEnding.balanceOf(liquidityPool2) == 1337_420_69);

        vm.stopPrank();
    }

    function test_transfer_TaxedNormalTransferMultiplePools() public
    {
        uint256 totalSupply = happyEnding.totalSupply();

        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);
        happyEnding.setLiquidityPool(liquidityPool2, true);
        happyEnding.transfer(address(0x1), totalSupply);

        vm.stopPrank();
        vm.startPrank(address(0x1));

        happyEnding.transfer(liquidityPool1, 1337_420_69);
        happyEnding.transfer(liquidityPool2, 1337_420_69);
        uint256 expectedTax = 133742;
        uint256 expectedLeftover = 133608327;

        assertTrue(happyEnding.balanceOf(marketingWallet) == expectedTax * 2);
        assertTrue(happyEnding.balanceOf(address(0x1)) == totalSupply - (1337_420_69 * 2));
        assertTrue(happyEnding.balanceOf(liquidityPool1) == expectedLeftover);
        assertTrue(happyEnding.balanceOf(liquidityPool2) == expectedLeftover);

        vm.stopPrank();
    }

    function test_transfer_ExcludedTaxedTransfer() public
    {
        uint256 totalSupply = happyEnding.totalSupply();

        vm.startPrank(contractCreator);

        happyEnding.setLiquidityPool(liquidityPool1, true);

        happyEnding.transfer(liquidityPool1, 1337_420_69);

        assertTrue(happyEnding.balanceOf(marketingWallet) == 0);
        assertTrue(happyEnding.balanceOf(contractCreator) == totalSupply - 1337_420_69);
        assertTrue(happyEnding.balanceOf(liquidityPool1) == 1337_420_69);

        vm.stopPrank();
    }

    //#endregion
}