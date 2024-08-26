// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token0 is ERC20 {
    constructor(uint256 initialSupply) ERC20("Token0", "TKN0") {
        _mint(msg.sender, initialSupply);
    }
}