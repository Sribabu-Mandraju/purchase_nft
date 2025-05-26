// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MSBToken} from "../src/MSBToken.sol";
import {BaseDeploy} from "../script/BaseDeploy.s.sol";
import {DenverNFT} from "../src/DenverNFT.sol";

contract TestDenver is Test {
    MSBToken token;
    DenverNFT nftContract;
    BaseDeploy factory;

    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address user1 = address(1);
    address user2 = address(3);
    address withDrawAddress = address(4);

    modifier mintTokens() {
        vm.prank(owner);
        token.mintTokens(user1, 100 * 1e18);
        _;
    }

    modifier purchaseNFT() {
        vm.prank(owner);
        token.mintTokens(user1, 100 * 1e18);
        vm.startPrank(user1);
        token.approve(address(nftContract), 5 * 1e18);
        nftContract.purchaseNFT(user1, "ROBO");
        vm.stopPrank();
        _;
    }

    function setUp() public {
        vm.startPrank(owner);
        token = new MSBToken();
        nftContract = new DenverNFT(address(token), withDrawAddress);
        vm.stopPrank();
    }

    // modifier mintTokens()

    function testOwner() public view {
        console.log("Actual owner:", token.owner());
        console.log("Expected owner:", owner);
        assertEq(token.owner(), owner);
    }

    function test_tokenAddress() public {
        assertEq(address(token), nftContract.getMSB_token());
    }

    function test_next_nftId() public {
        assertEq(nftContract.getNext_NFTId(), 0);
    }

    // unit testing of purchaseNFT

    function testPurchaseNFT() public mintTokens {
        vm.startPrank(user1);
        token.approve(address(nftContract), 5 * 1e18);
        nftContract.purchaseNFT(user1, "ROBO");
        vm.stopPrank();

        // assertionsas
        assertEq(nftContract.ownerOf(0), user1);
        assertEq(token.balanceOf(address(nftContract)), 5 * 1e18);
        assertEq(nftContract.getNext_NFTId(), 1);
        (uint256 lastPrice, string memory specAttr, bool canTrade,) = nftContract.nftFeatures(0);
        assertEq(specAttr, "ROBO");
        assertEq(lastPrice, 5 * 1e18);
        assertEq(canTrade, false);
    }

    function test_purchaseWith_insufficientBalance() public {
        vm.startPrank(user2);
        token.approve(address(nftContract), 5 * 1e18);
        vm.expectRevert();
        nftContract.purchaseNFT(user1, "ROBO");
        vm.stopPrank();
    }

    function testPriceOfNft() public purchaseNFT {
        vm.startPrank(user1);
        nftContract.setPriceOfNFT(4 * 1e18, 0);
        vm.stopPrank();
        uint256 newNFTCost = nftContract.nftCost(0);
        assertEq(newNFTCost, 4 * 1e18);
    }

    function test_Fail_changePriceOfNFT() public purchaseNFT {
        vm.startPrank(owner);
        vm.expectRevert();
        nftContract.setPriceOfNFT(4 * 1e18, 0);
        vm.stopPrank();
    }

    function test_makeNFT_Tradable() public purchaseNFT {
        vm.startPrank(user1);
        nftContract.makeNFT_Tradable(0);
        vm.stopPrank();
        (,, bool canTradable,) = nftContract.nftFeatures(0);
        assertEq(nftContract.ownerOf(0), user1);
        assertEq(canTradable, true);
    }

    function test_fail_makeNFT_Tradable() public purchaseNFT {
        vm.startPrank(owner);
        vm.expectRevert();
        nftContract.makeNFT_Tradable(0);
        vm.stopPrank();
        (,, bool canTradable,) = nftContract.nftFeatures(0);
        assertEq(nftContract.ownerOf(0), user1);
        assertEq(canTradable, false);
    }

    function test_makeNFT_Not_Tradable() public purchaseNFT {
        vm.startPrank(user1);
        nftContract.makeNFT_Tradable(0);

        nftContract.makeNFT_Not_Tradable(0);
        vm.stopPrank();

        (,, bool canTradable,) = nftContract.nftFeatures(0);
        assertEq(nftContract.ownerOf(0), user1);
        assertEq(canTradable, false);
    }

    function test_fail_makeNFT_Not_Tradable() public purchaseNFT {
        vm.startPrank(owner);
        vm.expectRevert();
        nftContract.makeNFT_Tradable(0);
        vm.expectRevert();
        nftContract.makeNFT_Not_Tradable(0);
        vm.stopPrank();

        (,, bool canTradable,) = nftContract.nftFeatures(0);
        assertEq(nftContract.ownerOf(0), user1);
        assertEq(canTradable, false);
    }

    function test_buyAlreadyOwnedNFT() public purchaseNFT {
        vm.prank(owner);
        token.mintTokens(user2, 100 * 1e18);

        vm.startPrank(user1);
        nftContract.makeNFT_Tradable(0);
        vm.stopPrank();

        vm.startPrank(user2);
        console.log("balance of user2 :",token.balanceOf(user2));
        token.approve(address(nftContract), 5 * 1e18);
        uint256 allo = token.allowance(user2,address(nftContract));
        console.log("allowance :",allo);
        nftContract.buyAlreadyOwnedNFT(0);
        vm.stopPrank();

        // assertEq(nftContract.ownerOf(0), user2);
    }
}
