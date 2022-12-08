// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/CryptoSave.sol";
import "src/SvgModel.sol";
import "src/WidgetNFT.sol";

contract DeployAll is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        SvgModel svgModel = new SvgModel();
        CryptoSave cryptoSave = new CryptoSave();
        WidgetNFT widgetNFT = new WidgetNFT();
        widgetNFT.setCryptoSaveAddress(address(cryptoSave));
        widgetNFT.setSvgModelAddress(address(svgModel));
        vm.stopBroadcast();
    }
}
