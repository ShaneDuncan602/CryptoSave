// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract CryptoSave is Ownable {
    uint8 public percentRise = 10;
    uint8 public percentFall = 10;
    uint256 public lastStablePrice;
    uint256 public lastCryptoPrice;

    ///This function is called from the external timer and is the entry point
    function poke() external returns (bool success) {
        //check oracle for spot price
    }

    /// Trade contract assets to stable coin
    function tradeToStable() internal {}

    /// Trade contract assets to crypto coin
    function tradeToCrypto() internal {}

    function setPercentRise(uint8 _percentRise) public {
        percentRise = _percentRise;
    }

    function setPercentFall(uint8 _percentFall) public {
        percentFall = _percentFall;
    }
}
