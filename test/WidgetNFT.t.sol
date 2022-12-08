// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/WidgetNFT.sol";
import "src/CryptoSave.sol";
import "src/SvgModel.sol";

contract WidgetNFTTest is Test {
    CryptoSave public cryptoSave;
    WidgetNFT public widgetNFT;
    SvgModel public svgModel;
    
    function setUp() public {
        cryptoSave = new CryptoSave();
        vm.deal(address(this), 10 ether);        
        cryptoSave.fundContract{value: 10 ether}(1500);
        cryptoSave.poke(0, 1200, 1);      
        svgModel = new SvgModel();
        widgetNFT = new WidgetNFT();
        widgetNFT.setCryptoSaveAddress(address(cryptoSave));  
        widgetNFT.setSvgModelAddress(address(svgModel));        
    }

    function testMint() public {
       cryptoSave.getIsInMoney();
       widgetNFT.mint();
       
       console.log(widgetNFT.tokenURI(1));
    }
}
