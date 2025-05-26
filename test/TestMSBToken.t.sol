// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MSBToken} from "../src/MSBToken.sol";
import {BaseDeploy} from "../script/BaseDeploy.s.sol";

contract TestMSBToken is Test {
    MSBToken token;
    BaseDeploy factory;
    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address user1 = address(1);
    address user2 = address(3);

    function setUp() public {
        // Deploy factory first
        factory = new BaseDeploy();

        // Then deploy token with owner context
        vm.prank(owner);
        token = new MSBToken(); // Direct deployment with owner context
    }

    function testOwner() public view {
        assertEq(token.owner(), owner);
    }

    function testMintFunction() public {
        vm.startPrank(owner);
        uint256 amount = 10 * 1e18;
        token.mintTokens(user1, amount);
        vm.stopPrank();

        assertEq(token.balanceOf(user1), amount);
    }

    function testMintRevert() public {
        vm.startPrank(user1);
        uint256 amount = 10 * 1e18;
        vm.expectRevert();
        token.mintTokens(user1, amount);
        vm.stopPrank();
    }
}
