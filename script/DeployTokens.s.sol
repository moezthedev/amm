// script/DeployTokens.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Token0.sol";
import "../src/Token1.sol";

contract DeployTokens is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint(PROCESS.env.PRIVATE_KEY);
        vm.startBroadcast(deployerPrivateKey);

        Token0 token0 = new Token0(1_000_000 * 10 ** 18); 
        Token1 token1 = new Token1(1_000_000 * 10 ** 18); 

        vm.stopBroadcast();

        console.log("Token0 deployed to:", address(token0));
        console.log("Token1 deployed to:", address(token1));
    }
}
