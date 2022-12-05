// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/CryptoSave.sol";

contract CounterTest is Test {
    CryptoSave public cryptoSave;

    function setUp() public {
        cryptoSave = new CryptoSave();
    }
}
