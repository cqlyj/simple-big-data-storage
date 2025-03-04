// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BigDataStore} from "./BigDataStore.sol";

/// @title BigNft
/// @author Luo Yingjie
/// @notice This contract allows users to mint NFTs with custom images, which stores the base64 encoded image data
contract BigNft is ERC721 {
    uint256 private s_lastTokenId = 0;
    mapping(uint256 tokenId => address imageStorage)
        private s_tokenIdToImageStorage;

    constructor() ERC721("BigNft", "BN") {}

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:image/png;base64,",
                    _loadBigData(s_tokenIdToImageStorage[tokenId])
                )
            );
    }

    function mint(
        string memory hugeImageBase64EncodedData
    ) public returns (uint256 tokenId) {
        tokenId = s_lastTokenId + 1;
        s_tokenIdToImageStorage[tokenId] = _storeBigData(
            hugeImageBase64EncodedData
        );

        _mint(msg.sender, tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _storeBigData(
        string memory data
    ) internal returns (address location) {
        return address(new BigDataStore(bytes(data)));
    }

    function _loadBigData(
        address location
    ) internal view returns (string memory data) {
        // location.code.length fetches the total length (in bytes) of the code at the given address.
        // The code subtracts 1 from the length, which implies that the first byte of the code is being skipped.
        // Because the first byte serves as a marker that isn’t part of the actual data payload.
        uint256 dataSize = location.code.length - 1;
        data = new string(dataSize);

        // Use extcodecopy instead of loc.code because we don't want the first (00) byte.

        // extcodecopy(address, memory_destination, code_offset, length)
        // - address: The target address whose bytecode is being copied.
        // - memory_destination: The starting memory location where the copied bytecode will be stored.
        // - code_offset: The offset within the bytecode from which to start copying.
        // - length: The number of bytes to copy.

        // The first 32 bytes store the length of the string.
        // The actual data starts at data + 32 (which is data + 0x20 in hexadecimal).
        // add(data, 0x20) moves the pointer past the length field to store the actual extracted bytes.

        // skip the first byte of the contract’s bytecode and start copying from byte index 1.
        assembly {
            extcodecopy(location, add(data, 0x20), 0x01, dataSize)
        }
    }
}
