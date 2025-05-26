// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MSBToken} from "../src/MSBToken.sol";
import {DenverNFT} from "../src/DenverNFT.sol";

contract BaseDeploy is Script {
    MSBToken msbToken;
    DenverNFT nftContract;

    function run() public returns (MSBToken, DenverNFT) {
        vm.startBroadcast();
        msbToken = new MSBToken();
        nftContract = new DenverNFT(address(msbToken), msg.sender);
        vm.stopBroadcast();
        return (msbToken, nftContract);
    }
}
