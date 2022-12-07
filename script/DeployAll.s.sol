// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/CryptoSave.sol";

contract DeployAll is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        CryptoSave cryptSave = new CryptoSave();
    }
}
