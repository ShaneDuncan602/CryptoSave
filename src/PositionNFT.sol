// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "base64-sol/base64.sol";

/**
 * @notice A dynamic NFT with a fully on-chain SVG for the CryptoSave address owner.
 * Dynamic elements are: Overall Position Status (Green Smiley emoji or Red Poo emoji)
 */

contract PositionNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string public smileyImageURI;
    string public pooImageURI;

    constructor() ERC721("CryptoSavePositionNFT", "CSP") {}

    function mintNFT() public onlyOwner {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId);
    }

    function addSmileyURI(string memory _svgSmileyURI) public onlyOwner {
        smileyImageURI = _svgSmileyURI;
    }   

    function addPooURI(string memory _svgPooURI) public onlyOwner {
        pooImageURI = _svgPooURI;
    }

    function addSmileySVG(string memory _svgSmileyRaw) public onlyOwner {
        string memory svgURI = svgToImageURI(_svgSmileyRaw);
        addSmileyURI(svgURI);
    }

    function addPooSVG(string memory _svgPooRaw) public onlyOwner {
        string memory svgURI = svgToImageURI(_svgPooRaw);
        addPooURI(svgURI);
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }
    
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        // assigning the pooImageURI as a default
        string memory imageURI = pooImageURI;
// WIP trying to figure out the threshold and incoming data to determine which ImageURI to assign
        // need to assign the smileyImageURI if position goes up
        //if (VARIABLE >= VARIABLE[tokenId]){
        //    imageURI = smileyImageURI;
        //}
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "CryptoSave NFT",
                                '", "description":"An NFT that changes based on the CryptoSave account position status", "attributes":"", "image":"',imageURI,'"}'
                            )
                        )
                    )
                )
            );
    }
}