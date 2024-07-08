// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DynamicPfp is ERC721, Ownable {
    error ERC721Metadata__URI_QueryFor_NonExistentToken();
    error DynamicPfp__UnAuthourized();

    enum DynamicState {
        Og,
        Punk
    }

    uint256 private s_tokenCounter;
    string private s_ogSvgUri;
    string private s_punkSvgUri;

    mapping(uint256 => DynamicState) private s_tokenIdToState;

    event CreatedNFT(uint256 indexed tokenId);

    constructor(string memory ogSvgUri, string memory punkSvgUri)
        ERC721("Dynamic yeahChibyke", "$DyC")
        Ownable(msg.sender)
    {
        s_tokenCounter = 0;
        s_ogSvgUri = ogSvgUri;
        s_punkSvgUri = punkSvgUri;
    }

    function mintNft() public {
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        s_tokenCounter++;
        emit CreatedNFT(tokenCounter);
    }

    function flipNft(uint256 tokenId) public {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert DynamicPfp__UnAuthourized();
        }
        if (s_tokenIdToState[tokenId] == DynamicState.Og) {
            s_tokenIdToState[tokenId] = DynamicState.Punk;
        } else {
            s_tokenIdToState[tokenId] = DynamicState.Og;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }

        string memory imageURI = s_ogSvgUri;

        if (s_tokenIdToState[tokenId] == DynamicState.Punk) {
            imageURI = s_punkSvgUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description":"This is the punk version of the OG yeahChibyke pfp.", ',
                            '"attributes": [{',
                            '"trait_type": "Type", "value": "Punk Demigod"}, ',
                            '{"trait_type": "Face", "value": "Stern"}, ',
                            '{"trait_type": "Hairstyle", "value": "Crazy Hair"}, ',
                            '{"trait_type": "Eyewear", "value": "Glasses"}, ',
                            '{"trait_type": "Facial Hair", "value": "Beard and Moustache"}], ',
                            '"image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    // Getter Functions
    function getOgSvg() external view returns (string memory) {
        return s_ogSvgUri;
    }

    function getPunkSvg() external view returns (string memory) {
        return s_punkSvgUri;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
