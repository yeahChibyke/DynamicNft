// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract FaceNft is ERC721, Ownable {
    // >------< Errors >-----<
    error FaceNft__UnAuthorized();
    error ERC721Metadata__URI_QueryFor_NonExistentToken();

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

    // >-----< Events >-----<
    event FaceNFTMinted(uint256 indexed tokenId);

    // >------< Constructor >-----<
    constructor(
        string memory nerdFaceSvgImageUri,
        string memory ninjaFaceSvgImageUri,
        string memory smileFaceSvgImageUri
    ) ERC721("Face NFT", "FNFT") Ownable(msg.sender) {
        s_tokenCounter = 0;
        s_nerdFaceSvgImageUri = nerdFaceSvgImageUri;
        s_ninjaFaceSvgImageUri = ninjaFaceSvgImageUri;
        s_smileFaceSvgImageUri = smileFaceSvgImageUri;
    }

    // >------< Functions >-----<
    function mintNft() public {
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        // s_tokenIdToFace[s_tokenCounter] = Face.NERD;
        s_tokenCounter++;

        emit FaceNFTMinted(tokenCounter);
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

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }
        string memory imageURI = s_nerdFaceSvgImageUri;

        if (s_tokenIdToFace[tokenId] == Face.NINJA) {
            imageURI = s_ninjaFaceSvgImageUri;
        } else if (s_tokenIdToFace[tokenId] == Face.SMILE) {
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

    // >-----< Getter Functions >-----<
    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getNerdFaceSvg() public view returns (string memory) {
        return s_nerdFaceSvgImageUri;
    }

    function getNinjaFaceSvg() public view returns (string memory) {
        return s_ninjaFaceSvgImageUri;
    }

    function getSmileFaceSvg() public view returns (string memory) {
        return s_smileFaceSvgImageUri;
    }

    function getAmountOfFaceOwned(address _holder) public view returns (uint256) {
        return balanceOf(_holder);
    }
}
