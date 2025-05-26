// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MSBToken} from "../src/MSBToken.sol";
import {DenverNFT} from "../src/DenverNFT.sol";

contract ConfigContracts {
    address constant tokenAddr = 0x851356ae760d987E095750cCeb3bC6014560891C;
    address constant nftAddr = 0xf5059a5D33d5853360D16C683c16e67980206f36;

    MSBToken internal token = MSBToken(tokenAddr);
    DenverNFT internal nftContract = DenverNFT(nftAddr);
}

contract MintTokens is Script, ConfigContracts {
    function run() public {
        vm.startBroadcast();
        token.mintTokens(msg.sender, 1000 * 1e18);
        vm.stopBroadcast();
    }
}

//nft market place interactions

contract PurchaseNFT is Script, ConfigContracts {
    function run() public {
        vm.startBroadcast();
        token.approve(nftAddr, 5 * 1e18);
        nftContract.purchaseNFT(msg.sender, "hello world");
        vm.stopBroadcast();
    }
}

contract WithDrwaTokens is Script, ConfigContracts {
    function run() public {
        vm.startBroadcast();
        nftContract.withDrawTokens();
        vm.stopBroadcast();
    }
}

contract NFT_tradable is Script, ConfigContracts {
    function run(uint256 _tokenId) public {
        vm.startBroadcast();
        nftContract.makeNFT_Tradable(_tokenId);
        vm.stopBroadcast();
    }
}

contract NFT_Not_Tradable is Script, ConfigContracts {
    function run(uint256 _tokenId) public {
        vm.startBroadcast();
        nftContract.makeNFT_Not_Tradable(_tokenId);
        vm.stopBroadcast();
    }
}

contract Set_Price_Of_NFT is Script, ConfigContracts {
    function run(uint256 _newPrice, uint256 _tokenId) public {
        vm.startBroadcast();
        nftContract.setPriceOfNFT(_newPrice, _tokenId);
        vm.stopBroadcast();
    }
}

contract SellNFT is Script, ConfigContracts {
    function run(uint256 _tokenId) public {
        vm.startBroadcast();
        nftContract.buyAlreadyOwnedNFT(_tokenId);
        vm.stopBroadcast();
    }
}
