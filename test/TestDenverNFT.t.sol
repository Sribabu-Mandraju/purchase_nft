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


    function setUp() public {
        // Deploy factory first
        
        factory = new BaseDeploy();
        vm.startPrank(owner);
        (token,nftContract) = factory.run();
        vm.stopPrank();
    }


    function test_tokenCounter() public view {
        // assertEq(nftContract.s_tokenCounter(),0);
        
    }
}
