// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title GasBadBigNft
/// @author Luo Yingjie
/// @notice This is the gas bad version of the BigNft contract
/// @notice This contract stores the base64 encoded image data directly in the contract
contract GasBadBigNft is ERC721 {
    uint256 private s_lastTokenId = 0;
    mapping(uint256 tokenId => string image) private s_tokenIdToImage;

    constructor() ERC721("GasBadBigNft", "GBBN") {}

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:image/png;base64,",
                    s_tokenIdToImage[tokenId]
                )
            );
    }

    function mint(
        string memory hugeImageBase64EncodedData
    ) public returns (uint256 tokenId) {
        tokenId = s_lastTokenId + 1;
        s_tokenIdToImage[tokenId] = hugeImageBase64EncodedData;

        _mint(msg.sender, tokenId);
    }
}
