// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

//import "lib/forge-std/src/console2.sol";

contract SimpleModel 
{
    // In reality these should bot be public and setter funcs should have owner/adminn guards
    // Just using default getters
    bool public isInMoney = true; 
    string public strLifetimePercent = '6.9';
    string public strSwapPercent = '4.2';
    string public assetHeldSymbol = 'ETH';

    constructor() {
        
    }

    function setIsInMoney(bool b) public {
        isInMoney = b;
    }

    function setLifetimePercent(string memory str) public {
        strLifetimePercent = str;
    }

    function setSwapPercent(string memory str) public {
        strSwapPercent = str;
    }

    function setSymbol(string memory str) public {
        assetHeldSymbol = str;
    }
}