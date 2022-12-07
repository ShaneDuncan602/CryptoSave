// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

//import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
//import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
//import "@solmate/utils/ReentrancyGuard.sol";
import "lib/forge-std/src/console2.sol";

error TokenDoesNotExist();

contract keeperNFT is ERC721, Owned 
{
    using Counters for Counters.Counter;
    Counters.Counter private supplyCounter;

    using Strings for uint256;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Owned(msg.sender)
    {
    }
  
    function mint() public payable
    {
        supplyCounter.increment();
        _mint(msg.sender, supplyCounter.current());
    }

    // WARNING: THIS MIGHT BE STUPID EXPENSIVE ???
    function buildSvg() private view returns (bytes memory) 
    {
        ISimpleModel SimpleModel = ISimpleModel(0x6e205f066F77712b4cB457d4D0197E1F9a49477D);

        string memory ARROW_LEFT_UP = "<path d='M18.988 447.717h6.749v17.753h17.244v-17.753h6.748L34.36 425.906' style='fill:#c0fdc0'/>";
        string memory ARROW_LEFT_DOWN = "<path d='M19.012 447.753h6.749v17.753h17.244v-17.753h6.748l-15.369-21.811' style='fill:#c0fdc0' transform='rotate(180 34.382 445.724)'/>";
        string memory ARROW_RIGHT_UP = "<path d='M356.267 447.717h6.749v17.753h17.244v-17.753h6.748l-15.369-21.811' style='fill:#c0fdc0'/>";
        string memory ARROW_RIGHT_DOWN = "<path d='M356.291 447.753h6.749v17.753h17.244v-17.753h6.748l-15.369-21.811' style='fill:#c0fdc0' transform='rotate(180 371.661 445.724)'/>";

        // Build the SVG

        string[8] memory parts;

        parts[0] = string.concat(
            "<svg viewBox='0 0 500 500' xmlns='http://www.w3.org/2000/svg'><path style='fill:#", 
            SimpleModel.isInMoney() ? "16cb19" : "cb1616" // BG_GREEN : BG_RED
            ); 

        parts[1] = "' d='M0 0h500v500H0z'/>";

        parts[2] = string.concat(
            SimpleModel.isInMoney() ? SimpleModel.getSmileEmoji() : SimpleModel.getPooEmoji(), 
            SimpleModel.isInMoney() ? ARROW_LEFT_UP : ARROW_LEFT_DOWN
            );

        parts[3] = string.concat(
            "<text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre' transform='matrix(.51199 0 0 .5273 -46.467 211.966)' x='211.757' y='466.61'>", 
            SimpleModel.strLifetimePercent()
            );

        parts[4] = "%</text><text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre;text-anchor:middle' transform='matrix(.51199 0 0 .5273 134.307 209.57)' x='211.757' y='466.61'>";

        parts[5] = string.concat(SimpleModel.assetHeldSymbol(), "</text>"); // Is concat cheaper than abi.encode ??
        
        parts[6] = string.concat(
            SimpleModel.isInMoney() ? ARROW_RIGHT_UP : ARROW_RIGHT_DOWN, 
            "<text style='fill:#dbfad4;font-family:Arial,sans-serif;font-size:64.6px;font-weight:700;stroke:#cceb68;white-space:pre' transform='matrix(.51199 0 0 .5273 290.812 211.966)' x='211.757' y='466.61'>"
            );

        parts[7] = string.concat(
            SimpleModel.strSwapPercent(), 
            "%</text><path style='fill:#d8d8d8;stroke:#cceb68' transform='rotate(89.995 161.328 435.362)' d='m117.886 435.308 86.884.108'/><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;text-anchor:middle;white-space:pre' transform='translate(55.227 -10.244)'><tspan x='24.819' y='392.296'>LIFETIME OF</tspan><tspan x='24.819' dy='1em'></tspan></text><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:23px;font-weight:700;white-space:pre;text-anchor:middle' x='243.256' y='391.533'>ASSET</text><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;white-space:pre;text-anchor:middle' transform='translate(54.882 -18.474)'><tspan x='361.222' y='398.644'>SINCE LAST</tspan><tspan x='361.222' dy='1em'></tspan></text><path style='fill:#d8d8d8;stroke:#cceb68' transform='rotate(89.995 328.613 435.362)' d='m285.171 435.308 86.884.108'/><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;text-anchor:middle;white-space:pre' transform='translate(53.925 10.098)'><tspan x='24.819' y='392.296'>POSITION</tspan><tspan x='24.819' dy='1em'></tspan></text><text style='fill:#f8ffbf;font-family:Arial,sans-serif;font-size:21px;font-weight:700;white-space:pre;text-anchor:middle' transform='translate(54.882 1.839)'><tspan x='361.222' y='398.644'>SWAP</tspan><tspan x='361.222' dy='1em'></tspan></text></svg>"
            );

        //return string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7]));
        bytes memory image = abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(
                bytes(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7]))));
        return image;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0))
            revert TokenDoesNotExist();

        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', Strings.toString(tokenId), '",',
                    '"image_data": "', buildSvg(), '",',
                    '"description": "Keep your wallet heavy and your head above water"}'
                )
            ))
        );

        return string(abi.encodePacked('data:application/json;base64,', json));
    }
}

// Interface to Model

interface ISimpleModel {
    function isInMoney() external view returns (bool);
    function strLifetimePercent() external view returns (string memory);
    function strSwapPercent() external view returns (string memory);
    function assetHeldSymbol() external view returns (string memory);

    function getSmileEmoji() external view returns (string memory);
    function getPooEmoji() external view returns (string memory);
}