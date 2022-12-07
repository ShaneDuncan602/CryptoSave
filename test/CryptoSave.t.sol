// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/CryptoSave.sol";

contract CryptoSaveTest is Test {
    CryptoSave public cryptoSave;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IWETH public weth = IWETH(WETH);
    IERC20 public dai = IERC20(DAI);

    function setUp() public {
        cryptoSave = new CryptoSave();        
    }

    function testPokeStable() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();

        cryptoSave.poke(0, 100, 100);
        console.log("<><><><><><>STABLE:");
        console.logUint(cryptoSave.getStableAmount());
        assertGe(cryptoSave.getStableAmount(),12596504387286394754700);
    }

    function testPokeCrypto() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();

        cryptoSave.poke(0, 100, 100);
        console.log("<><><><><><>STABLE:");
        console.logUint(cryptoSave.getStableAmount());
        assertGe(cryptoSave.getStableAmount(),12596504387286394754700);
        cryptoSave.poke(1, 100, 100);
        console.log("<><><><><><>CRYPTO:");
        console.logUint(cryptoSave.getCryptoAmount());
        assertGe(cryptoSave.getCryptoAmount(),9940095876057083000);
    }

    function testFund() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();
    }

    function testCashOutWhenWeth() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();
        cryptoSave.cashOut();        
        console.log("<><><><><><>WETH:");
        console.logUint(weth.balanceOf(address(this)));
        assertGt(weth.balanceOf(address(this)),9999999999999999990);        
    }

    function testCashOutWhenDAI() public {
        vm.deal(address(this), 10 ether);
        cryptoSave.fundContract{value: 10 ether}();
        cryptoSave.poke(0, 100, 100);
        cryptoSave.cashOut();
        console.log("<><><><><><>DAI:");
        console.logUint(dai.balanceOf(address(this)));
        assertGt(dai.balanceOf(address(this)),9999999999999999990);
        
    }
}
