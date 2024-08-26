// Token0.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Token0 is ERC20 {
    constructor() ERC20("Token0", "T0") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
