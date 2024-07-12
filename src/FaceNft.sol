// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract FaceNft is ERC721 {
    // >------< Errors >-----<
    error FaceNft__UnAuthorized();

    // >------< Variables >-----<
    uint256 private s_tokenCounter;
    string private s_nerdFaceSvgImageUri;
    string private s_ninjaFaceSvgImageUri;
    string private s_smileFaceSvgImageUri;

    // >------< Enums >-----<
    enum Face {
        NERD,
        NINJA,
        SMILE
    }

    // >------< Mapping >-----<
    mapping(uint256 tokenId => Face) private s_tokenIdToFace;

    // >------< Constructor >-----<
    constructor(
        string memory nerdFaceSvgImageUri,
        string memory ninjaFaceSvgImageUri,
        string memory smileFaceSvgImageUri
    ) ERC721("Face NFT", "FNFT") {
        s_tokenCounter = 0;
        s_nerdFaceSvgImageUri = nerdFaceSvgImageUri;
        s_ninjaFaceSvgImageUri = ninjaFaceSvgImageUri;
        s_smileFaceSvgImageUri = smileFaceSvgImageUri;
    }

    // >------< Functions >-----<
    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToFace[s_tokenCounter] = Face.NERD;
        s_tokenCounter++;
    }

    function flipFaceToNerd(uint256 tokenId) public {
        // require only NFT owner can flip face
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert FaceNft__UnAuthorized();
        }
        if (s_tokenIdToFace[tokenId] == Face.NINJA) {
            s_tokenIdToFace[tokenId] = Face.NERD;
        } else if (s_tokenIdToFace[tokenId] == Face.SMILE) {
            s_tokenIdToFace[tokenId] = Face.NERD;
        } else {
            s_tokenIdToFace[tokenId] = Face.NERD;
        }
    }

    function flipFaceToNinja(uint256 tokenId) public {
        // require only Nft owner can flip face
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert FaceNft__UnAuthorized();
        }
        if (s_tokenIdToFace[tokenId] == Face.NERD) {
            s_tokenIdToFace[tokenId] = Face.NINJA;
        } else if (s_tokenIdToFace[tokenId] == Face.SMILE) {
            s_tokenIdToFace[tokenId] = Face.NINJA;
        } else {
            s_tokenIdToFace[tokenId] = Face.NINJA;
        }
    }

    function flipFaceToSmile(uint256 tokenId) public {
        // require only Nft owner can flip face
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert FaceNft__UnAuthorized();
        }
        if (s_tokenIdToFace[tokenId] == Face.NERD) {
            s_tokenIdToFace[tokenId] = Face.SMILE;
        } else if (s_tokenIdToFace[tokenId] == Face.NINJA) {
            s_tokenIdToFace[tokenId] = Face.SMILE;
        } else {
            s_tokenIdToFace[tokenId] = Face.SMILE;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;

        if (s_tokenIdToFace[tokenId] == Face.NERD) {
            imageURI = s_nerdFaceSvgImageUri;
        } else if (s_tokenIdToFace[tokenId] == Face.NINJA) {
            imageURI = s_ninjaFaceSvgImageUri;
        } else {
            imageURI = s_smileFaceSvgImageUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description":"Face NFT that represents the personality of the owner.", ',
                            '"attributes": [{',
                            '"trait_type": "Type", "value": "Svg Image"}, ',
                            '{"trait_type": "Personality", "value": "100%"}, ',
                            '"image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
