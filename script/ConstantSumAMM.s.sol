// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/ConstantSumAMM.sol";

contract DeployConstantSumAMM is Script {
    function run() external {
      
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

       
        vm.startBroadcast(deployerPrivateKey);

       
        address token0 = 0x61437f24283E0538f60b247Ba8726f504dEd02B8;
        address token1 = 0x5F2F6EfF688bd4A5798867512a6F17659BfF426c;

       
        ConstantSumAMM amm = new ConstantSumAMM(token0, token1);

       
        vm.stopBroadcast();

        
        console.log("ConstantSumAMM deployed to:", address(amm));
    }
}
