// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/HappyEndingToken.sol";

contract HappyEndingTest is Test
{
    HappyEndingToken happyEnding;

    function setUp() public {
        happyEnding = new HappyEndingToken();
    }
}