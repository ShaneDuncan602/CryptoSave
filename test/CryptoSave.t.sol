// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/CryptoSave.sol";

contract CryptoSaveTest is Test {
    CryptoSave public cryptoSave;

    function setUp() public {
        cryptoSave = new CryptoSave();
    }

    function testPokeStable() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();

        cryptoSave.poke(0);
        console.log("<><><><><><>STABLE:");
        console.logUint(cryptoSave.getStableAmount());
    }

    function testPokeCrypto() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();

        cryptoSave.poke(0);
        console.log("<><><><><><>STABLE:");
        console.logUint(cryptoSave.getStableAmount());
        cryptoSave.poke(1);
        console.log("<><><><><><>CRYPTO:");
        console.logUint(cryptoSave.getCryptoAmount());
    }

    function testFund() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();
    }
}
