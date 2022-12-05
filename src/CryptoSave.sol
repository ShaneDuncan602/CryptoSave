// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

contract CryptoSave {
    uint8 public percentRise;
    uint8 public percentFall;

    function setPercentRise(uint8 _percentRise) public {
        percentRise = _percentRise;
    }

    function setPercentFall(uint8 _percentFall) public {
        percentFall = _percentFall;
    }
}
