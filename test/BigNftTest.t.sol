// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {BigNft} from "src/BigNft.sol";

contract BigNftTest is Test {
    BigNft public bigNft;
    // example base64 encoded png image
    string constant BASE64_PNG =
        "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAAAklEQVR4nGKkkSsAAAEXSURBVO3WIQ7CMBQG4Np5HME2CAwKicfgMEhOAHfgCmiugOUAnAHNRcbCkmZ53Wv7miWl7f/ymy1t+L+k21Cn6y3rqOQNAEjdAIDUDQBI3eDvAIoZAABw9zOj17vRuHcBENyb60fSvlWfwPXREgBKBUgDQPEAW9L+hlyaO+TSu15aAwBr8jtCAKQGnLeLYTiYdACoBzDt2D90fzy7AOA7Qt5m5KQdtCIBoBIAV0gKMPcvm6YPAJUDOAm3jNsIQDAgoiIAAIxK9qtZl8B+DjYAlQNMpEffbOQAoX0AkMV+m7kHgGoBy3lD0u96Bc/nqLt4JQDkCyBvw/yegUIA9odJKpEWAKBUAPf3M/pwA1A5YKp+AAAAgCdfgXWDFWuL1n4AAAAASUVORK5CYII=";
    address public USER = makeAddr("USER");

    function setUp() external {
        bigNft = new BigNft();
    }

    function testMintWorks() external {
        vm.prank(USER);
        bigNft.mint(BASE64_PNG);

        assertEq(bigNft.ownerOf(1), USER);
    }

    function testTokenURIWorks() external {
        vm.prank(USER);
        bigNft.mint(BASE64_PNG);

        string memory tokenURI = bigNft.tokenURI(1);
        assert(
            keccak256(abi.encodePacked(tokenURI)) ==
                keccak256(
                    abi.encodePacked("data:image/png;base64,", BASE64_PNG)
                )
        );
    }
}
