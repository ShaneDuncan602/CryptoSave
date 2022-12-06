//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract DynamicNFT is ERC721 {

    uint256 tokenId;

    mapping(uint256 => string) public nft;

    constructor() ERC721("Dynamic", "DYN") {
        tokenId = 0;
    }

    function mint(string memory nftString) external {
        tokenId++;
        super._mint(msg.sender, tokenId);
        nft[tokenId] = nftString;
    }

    function update(uint256 _tokenId, string memory nftUpdate) public {
        require(ownerOf(_tokenId) != address(0));
        nft[_tokenId] = nftUpdate;
    }
}