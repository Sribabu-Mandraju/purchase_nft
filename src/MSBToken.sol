// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MSBToken is ERC20, Ownable {
    constructor() ERC20("MSBToken", "MSB") Ownable(msg.sender) {}

    function mintTokens(address _to, uint256 amount) public {
        require(msg.sender == owner(), "only owner can mint new tokens");
        _mint(_to, amount);
    }
}
