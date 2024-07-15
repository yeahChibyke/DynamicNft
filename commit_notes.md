# 15/07/2024

- NFTs are not loading in OpenSea. About to do some very ungodly refactoring, stick with me. In the meantime, this is the current of contracts:

  - ### FaceNft.sol
    ```solidity
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
    ```

  - ### DeployFaceNft.s.sol
    ```solidity
        // SPDX-License-Identifier: SEE LICENSE IN LICENSE
        pragma solidity >= 0.8.0;

        import {Script, console2} from "forge-std/Script.sol";
        import {FaceNft} from "../src/FaceNft.sol";
        import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

        contract DeployFaceNft is Script {
            function run() external returns (FaceNft) {
                string memory nerdFaceSvg = vm.readFile("./img/nerdFace.svg");
                string memory ninjaFaceSvg = vm.readFile("./img/ninjaFace.svg");
                string memory smileFaceSvg = vm.readFile("./img/smileFace.svg");

                vm.startBroadcast();
                FaceNft faceNft =
                    new FaceNft(svgToImageURI(nerdFaceSvg), svgToImageURI(ninjaFaceSvg), svgToImageURI(smileFaceSvg));
                vm.stopBroadcast();
                return faceNft;
            }

            function svgToImageURI(string memory svg) public pure returns (string memory) {
                string memory baseURL = "data:image/svg+xml;base64,";
                string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
                return string(abi.encodePacked(baseURL, svgBase64Encoded));
            }
        }
    ```

  - ### TestFaceNft.t.sol
    ```solidity
        // SPDX-License-Identifier: SEE LICENSE IN LICENSE
        pragma solidity >= 0.8.0;

        import {Test, console2} from "forge-std/Test.sol";
        import {FaceNft} from "../src/FaceNft.sol";
        import {DeployFaceNft} from "../script/DeployFaceNft.s.sol";

        contract TestFaceNft is Test {
            FaceNft public faceNft;
            DeployFaceNft public deployer;

            string public constant NERD_FACE_TOKEN_URI =
                "data:application/json;base64,eyJuYW1lIjoiRmFjZSBORlQiLCAiZGVzY3JpcHRpb24iOiJGYWNlIE5GVCB0aGF0IHJlcHJlc2VudHMgdGhlIHBlcnNvbmFsaXR5IG9mIHRoZSBvd25lci4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiVHlwZSIsICJ2YWx1ZSI6ICJTdmcgSW1hZ2UifSwgeyJ0cmFpdF90eXBlIjogIlBlcnNvbmFsaXR5IiwgInZhbHVlIjogIjEwMCUifSwgImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpT0RBd2NIZ2lJR2hsYVdkb2REMGlPREF3Y0hnaUlIWnBaWGRDYjNnOUlqQWdNQ0EyTkNBMk5DSWdlRzFzYm5NOUltaDBkSEE2THk5M2QzY3Vkek11YjNKbkx6SXdNREF2YzNabklpQjRiV3h1Y3pwNGJHbHVhejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TVRrNU9TOTRiR2x1YXlJZ1lYSnBZUzFvYVdSa1pXNDlJblJ5ZFdVaUlISnZiR1U5SW1sdFp5SWdZMnhoYzNNOUltbGpiMjVwWm5rZ2FXTnZibWxtZVMwdFpXMXZhbWx2Ym1VdGJXOXViM1J2Ym1VaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVdSWlRXbGtJRzFsWlhRaVBqeHdZWFJvSUdROUlrMHpNaUF5UXpFMUxqUXpNaUF5SURJZ01UVXVORE15SURJZ016SnpNVE11TkRNeUlETXdJRE13SURNd2N6TXdMVEV6TGpRek1pQXpNQzB6TUZNME9DNDFOamdnTWlBek1pQXliVEU0TGpFd015QTVMak15TkdFeE5pNDBNVGdnTVRZdU5ERTRJREFnTUNBd0xUZ3VPVGM1TFM0NU1UVmpMUzQzTURNdU1UTTFMUzR4T1RJZ01pNHlOeTR6T0RnZ01pNHhOVFpqTkM0eE5qZ3RMamMwT0NBNExqUTFOaTQwSURFeExqWTVJRE11TVRNell5NHhOak11TVRReUxqUTJPUzR3TVRVdU56WTFMUzR5TWpKaE1qY3VORGt4SURJM0xqUTVNU0F3SURBZ01TQTBMakEySURjdU5qWkROVFV1TnpNZ01Ua3VORFUySURVeExqWTFOeUF4TnlBME55QXhOMk10TkM0MU16TWdNQzA0TGpVeU1TQXlMak15TXkweE1DNDRORGdnTlM0NE5ESmpMVEl1TmpnNExURXVNVFk0TFRVdU9EQTFMVEV1TURZeExUZ3VNekF4TGpBd04wTXlOUzQxTWpVZ01Ua3VNekkySURJeExqVXpOeUF4TnlBeE55QXhOMk10TkM0Mk5UY2dNQzA0TGpjeklESXVORFUzTFRFeExqQXlOaUEyTGpFek4yRXlOeTQwTmpnZ01qY3VORFk0SURBZ01DQXhJRFF1TVRNMkxUY3VOelU0WXk0eU55NHhPVGN1TlRNNExqSTVPUzQyT0RZdU1UWTVZVEUwTGpJek15QXhOQzR5TXpNZ01DQXdJREVnTVRFdU5qa3lMVE11TVRNell5NDFPQzR4TVRNZ01TNHdPVEl0TWk0d01qRXVNemc1TFRJdU1UVTJZVEUyTGpReE1TQXhOaTQwTVRFZ01DQXdJREF0T0M0Mk56SXVPRU14T1M0d01EWWdOaTQ1TnpNZ01qVXVNakU0SURRdU5TQXpNaUEwTGpWak5pNDVNamdnTUNBeE15NHlOaklnTWk0MU9ERWdNVGd1TVRBeklEWXVPREkwVFRVM0lETXdZekFnTlM0MU1qRXROQzQwTnprZ01UQXRNVEFnTVRCekxURXdMVFF1TkRjNUxURXdMVEV3WXpBdE5TNDFNalFnTkM0ME56a3RNVEFnTVRBdE1UQnpNVEFnTkM0ME56WWdNVEFnTVRCdExUSTVMams1T1NBd1l6QWdOUzQxTWpNdE5DNDBOemtnTVRBdE1UQXVNREF4SURFd1l5MDFMalV5TWlBd0xURXdMVFF1TkRjM0xURXdMVEV3WXpBdE5TNDFNalFnTkM0ME56Y3RNVEFnTVRBdE1UQnpNVEF1TURBeElEUXVORGMySURFd0xqQXdNU0F4TUUwek1pQTFPUzQxWXkweE5DNDFOak1nTUMweU5pNDFNVEV0TVRFdU16YzVMVEkzTGpRek5pMHlOUzQzTVRKRE5pNHhPRGNnTXprdU1URTVJREV4TGpFek9TQTBNeUF4TnlBME0yTTNMakU0SURBZ01UTXROUzQ0TWlBeE15MHhNMk13TFRFdU1qYzJMUzR4T1RFdE1pNDFNRFl0TGpVek5DMHpMalkzTVdNeExqVXpMUzQwTXpZZ015NDFOQzB1TkRNMElEVXVNRFk0TGpBd01VRXhNaTQ1TmpRZ01USXVPVFkwSURBZ01DQXdJRE0wSURNd1l6QWdOeTR4T0NBMUxqZ3lJREV6SURFeklERXpZelV1T0RZeElEQWdNVEF1T0RFekxUTXVPRGd4SURFeUxqUXpOaTA1TGpJeE1rTTFPQzQxTVRFZ05EZ3VNVEl4SURRMkxqVTJNeUExT1M0MUlETXlJRFU1TGpVaUlHWnBiR3c5SWlNd01EQXdNREFpUGp3dmNHRjBhRDQ4Wld4c2FYQnpaU0JqZUQwaU1qQWlJR041UFNJek1DNDFJaUJ5ZUQwaU5DSWdjbms5SWpVaUlHWnBiR3c5SWlNd01EQXdNREFpUGp3dlpXeHNhWEJ6WlQ0OFpXeHNhWEJ6WlNCamVEMGlORFFpSUdONVBTSXpNQzQxSWlCeWVEMGlOQ0lnY25rOUlqVWlJR1pwYkd3OUlpTXdNREF3TURBaVBqd3ZaV3hzYVhCelpUNDhjR0YwYUNCa1BTSk5OREV1TkRBMElEUTFMakUxWXkwekxqSXlNeUF5TGpJMk9TMDRMak0xTXlBekxqZ3pOQzB4TXk0Mk5pQXlMalF6TTJNdE1TNDBNakV0TGpNM055MHlMalV6TlNBekxqTXhMVEV1TURFNElETXVOek16WXpVdU56WTNJREV1TlRVZ01USXVNRFE1TGpReU9TQXhOaTQ1TXkwekxqQXhOR014TGpJd05TMHVPRFk0TFRFdU1EVTBMVFF1TURJM0xUSXVNalV5TFRNdU1UVXlJaUJtYVd4c1BTSWpNREF3TURBd0lqNDhMM0JoZEdnK1BDOXpkbWMrIn0=";
            string public constant NINJA_FACE_TOKEN_URI =
                "data:application/json;base64,eyJuYW1lIjoiRmFjZSBORlQiLCAiZGVzY3JpcHRpb24iOiJGYWNlIE5GVCB0aGF0IHJlcHJlc2VudHMgdGhlIHBlcnNvbmFsaXR5IG9mIHRoZSBvd25lci4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiVHlwZSIsICJ2YWx1ZSI6ICJTdmcgSW1hZ2UifSwgeyJ0cmFpdF90eXBlIjogIlBlcnNvbmFsaXR5IiwgInZhbHVlIjogIjEwMCUifSwgImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpT0RBd2NIZ2lJR2hsYVdkb2REMGlPREF3Y0hnaUlIWnBaWGRDYjNnOUlqQWdNQ0ExTVRJZ05URXlJaUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQanh3WVhSb0lHWnBiR3c5SWlNd01EQXdNREFpSUdROUlrMHlPREF1TURVMElERTVMamcyTjJNdE5qUXVNekUxSURBdE1USXhMamMySURJNExqYzVNeTB4TlRrdU5qUXpJRGN6TGprek5DQXlOeTR6T0RjdU1EY2dPRGN1T1RJNElETXVNRFVnT1RZdU1USWdNalV1TnpJMkxUTTRMalF4TkMweE1pNHhNRFV0TnprdU56VXpMVEV4TGpJMkxURXdPQzQxTXpRdE9TNHpNREpoTWpBeExqQXhNeUF5TURFdU1ERXpJREFnTUNBd0xURXpMalkxTmlBeU15NHpNVFJqTXpFdU5UQTNMVGd1TXpBM0lERTBOeTQ1T1RndE15NHpOeUF4TlRRdU9DQXlNUzR5TmpndE56VXVPVGcxTFRFNExqWXlOQzB4TkRBdU5Ua3RPQzQyTlMweE5qSXVNRFU0TFRRdU9EazFMVGd1TnpZNElESXlMalEwTmkweE15NDFPRFFnTkRZdU9EQTFMVEV6TGpVNE5DQTNNaTR5TnpJZ01DQXhNVEV1TnpNMklEazJMakkwT0NBeU5qa3VPVFE1SURJeE1DNHpNalFnTWpZNUxqazBPU0ExTnk0NE1EZ2dNQ0F4TURrdU1TMDBNQzQyTXlBeE5EVXVOak0zTFRrMUxqSTBPQzB6TVM0ME1ETWdNak11T0RFeUxUazRMakEwSURVM0xqTXdPQzB4TXprdU1EQXlJRE0wTGpZME9DQTRNUzQxT1RJdE9DNDVPVFFnTVRNNUxqazJOUzAxTUM0NU56Z2dNVFUyTGpFNUxUWXpMak0xTXlBeU5TNHlNRGN0TkRjdU1UUXlJRE01TGprMU9TMHhNREF1TkRNeUlETTVMamsxT1MweE5EVXVPVGsySURBdE1URXhMamN6TnkwNU1pNDBOemN0TWpBeUxqTXhOeTB5TURZdU5UVXpMVEl3TWk0ek1UZDZiUzB1TURBeUlERTFNUzQyT1RKak1UQTFMakE0TkNBd0lERTVNQzR5TnpNZ01qY3VOekkzSURFNU1DNHlOek1nTmpFdU9UTXhJREFnTWpJdU1EUTNMVFF1TkRrMUlETXpMalE0TFRVM0xqYzVOeUEwTkM0ME5UTXRNamt1TXprZ05pNHdOVEl0T1RVdU1USTNMVE14TGpFNE1TMHhNekl1TkRjMkxUTXhMakU0TVMwek5DNDROalFnTUMwNE55NHhNaUEwTVM0ek5EVXRNVEUxTGpJeE9TQXpOaTR3TVRjdE5UWXVOVGszTFRFd0xqY3pNaTAzTlM0d05UTXRNall1TkRNekxUYzFMakExTXkwME9TNHlPRGtnTUMwek5DNHlNRFFnT0RVdU1UZzRMVFl4TGprek1TQXhPVEF1TWpjeUxUWXhMamt6TVhwdE9ETXVPRGcxSURNNUxqZzVOR010TWpBdU1UUXRMakV5TFRReExqVTNNU0F6TGpJNU5TMDBNUzQwTnpVZ09TNDVNUzR4T0RJZ01USXVORFV6SURFM0xqTTJOQ0F5TWk0eU9UZ2dNemd1TXpjM0lESXhMams1SURJeExqQXhNeTB1TXpBMklERTRMalUxTlMweE5pNHlNVFlnTXpjdU56RTNMVEl6TGpFd01TMHVNRGcxTFRVdU9ETTNMVEUyTGpnMUxUZ3VOamt6TFRNMExqWXlMVGd1TnprNWVtMHRNVGN5TGpZNE1pQXlMamc0TTJNdE1UY3VOemN1TVRBMUxUTTBMalV6TkNBeUxqazJOQzB6TkM0Mk1pQTRMamdnTVRrdU1UWXlJRFl1T0RnMUlERTJMamN3TkNBeU1pNDNPVFlnTXpjdU56RTRJREl6TGpFd01pQXlNUzR3TVRNdU16QTNJRE00TGpFNU5TMDVMalUwSURNNExqTTNOeTB5TVM0NU9USXVNRGsyTFRZdU5qRTFMVEl4TGpNek5pMHhNQzR3TXkwME1TNDBOelV0T1M0NU1YcHRPVEl1TlRjZ09ESXVORFF4WXpNeExqQXpNaUF3SURVMkxqRTRPQ0F5TlM0eU16VWdOVFl1TVRnNElESTFMakl6TlhNdE1qZ3VNVGcwTFRFeExqRXdOQzAxT1M0eU1UY3RNVEV1TVRBMFl5MHpNUzR3TXpJZ01DMDFNeTR4TmlBeE1TNHhNRFF0TlRNdU1UWWdNVEV1TVRBMGN6STFMakUxTmkweU5TNHlNelVnTlRZdU1Ua3RNalV1TWpNMWVrMHpNUzR5TlNBME1URXVNemxqTkM0ek5EUWdNaTR3TkRZZ055NDNPRE10TkRBdU16TTJJRFV5TGpJME5pMDJNUzR5TmpVdE9DNHhNVEV0T0M0ME5qVXRNVEl1TkRNNExUSTBMall6T0MweE5DNHlOQzB6TlM0MU1ESXRNekl1TnpNeklEUXVNVFU0TFRVMUxqQXhNaUE0TkM0NE9EY3RNemd1TURBMklEazJMamMyTjNwdE5UWXVNekV0TkRFdU5qazBZeTAzTGpVeE1TMHVNRFV5TFRFM0xqSTJMUzR5TWpndE1UY3VORFExSURFMkxqa3pOeTB1TkRrNElEUTJMak14TFRReUxqZ3dOU0E1Tmk0NU5UTXROREF1TVRJNElEazRMakl4TlNBM0xqRXpPQ0F6TGpNMk5DQTBPUzQxT1RndE16SXVNRGMzSURZeExqa3dOaTAxT1M0ME5DQTBMakUxT1MwNUxqSTBOQ0F4TVM0MU1UWXROVFV1TmpBekxUUXVNek16TFRVMUxqY3hNbm9pTHo0OEwzTjJaejQ9In0=";
            string public constant SMILE_FACE_TOKEN_URI =
                "data:application/json;base64,eyJuYW1lIjoiRmFjZSBORlQiLCAiZGVzY3JpcHRpb24iOiJGYWNlIE5GVCB0aGF0IHJlcHJlc2VudHMgdGhlIHBlcnNvbmFsaXR5IG9mIHRoZSBvd25lci4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiVHlwZSIsICJ2YWx1ZSI6ICJTdmcgSW1hZ2UifSwgeyJ0cmFpdF90eXBlIjogIlBlcnNvbmFsaXR5IiwgInZhbHVlIjogIjEwMCUifSwgImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCb1pXbG5hSFE5SWpnd01IQjRJaUIzYVdSMGFEMGlPREF3Y0hnaUlIWmxjbk5wYjI0OUlqRXVNU0lnYVdROUlrTmhjR0ZmTVNJZ2VHMXNibk05SW1oMGRIQTZMeTkzZDNjdWR6TXViM0puTHpJd01EQXZjM1puSWlCNGJXeHVjenA0YkdsdWF6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNVGs1T1M5NGJHbHVheUlnRFFvSklIWnBaWGRDYjNnOUlqQWdNQ0EwTlRJdU9UZzJJRFExTWk0NU9EWWlJSGh0YkRwemNHRmpaVDBpY0hKbGMyVnlkbVVpUGcwS1BHYytEUW9KUEdjK0RRb0pDVHhuUGcwS0NRa0pQSEJoZEdnZ2MzUjViR1U5SW1acGJHdzZJekF4TURBd01qc2lJR1E5SWsweU1qWXVORGt6TERCRE1UQXhMalUzTnl3d0xEQXNNVEF4TGpVM055d3dMREl5Tmk0ME9UTmpNQ3d4TWpRdU9EY3pMREV3TVM0MU56Y3NNakkyTGpRNU15d3lNall1TkRrekxESXlOaTQwT1RNTkNna0pDUWxqTVRJMExqZzFNaXd3TERJeU5pNDBPVE10TVRBeExqWXlMREl5Tmk0ME9UTXRNakkyTGpRNU0wTTBOVEl1T1RnMkxERXdNUzQxTnpjc016VXhMak0wTlN3d0xESXlOaTQwT1RNc01Ib2dUVEl5Tmk0ME9UTXNOREkzTGpjNU1nMEtDUWtKQ1dNdE1URXhMakEwTml3d0xUSXdNUzR6TWkwNU1DNHlPVFV0TWpBeExqTXlMVEl3TVM0eU9UbGpNQzB4TVRFdU1ESTFMRGt3TGpJM05DMHlNREV1TXpReUxESXdNUzR6TWkweU1ERXVNelF5WXpFeE1DNDVPRElzTUN3eU1ERXVNamMzTERrd0xqTXhOeXd5TURFdU1qYzNMREl3TVM0ek5ESU5DZ2tKQ1FsRE5ESTNMamMzTERNek55NDBPVFlzTXpNM0xqUTNOU3cwTWpjdU56a3lMREl5Tmk0ME9UTXNOREkzTGpjNU1ub2lMejROQ2drSkNUeHdZWFJvSUhOMGVXeGxQU0ptYVd4c09pTXdNVEF3TURJN0lpQmtQU0pOTVRRM0xqSTROU3d5TWpJdU5UQXpZekUyTGpneU5Td3dMRE13TGpRMU9DMHhNeTQxTkRZc016QXVORFU0TFRNd0xqTTFZekF0TVRZdU9EQTBMVEV6TGpZek15MHpNQzR6T1RNdE16QXVORFU0TFRNd0xqTTVNdzBLQ1FrSkNXTXRNVFl1TnpFM0xEQXRNekF1TXprekxERXpMalU1TFRNd0xqTTVNeXd6TUM0ek9UTlRNVE13TGpVMk9Dd3lNakl1TlRBekxERTBOeTR5T0RVc01qSXlMalV3TTNvaUx6NE5DZ2tKQ1R4amFYSmpiR1VnYzNSNWJHVTlJbVpwYkd3Nkl6QXhNREF3TWpzaUlHTjRQU0l6TURVdU5qTTJJaUJqZVQwaU1Ua3lMakV6TVNJZ2NqMGlNekF1TXpjeUlpOCtEUW9KQ1FrOGNHRjBhQ0J6ZEhsc1pUMGlabWxzYkRvak1ERXdNREF5T3lJZ1pEMGlUVEl5Tmk0ME9UTXNNemMxTGpZMU5XTTJNQzR6T1Rnc01Dd3hNVEl1TURFM0xUTTJMakE0T0N3eE16VXVOVEE0TFRnM0xqYzNNa2c1TVM0d01EY05DZ2tKQ1FsRE1URTBMalF4TVN3ek16a3VOVFkzTERFMk5pNHdNeXd6TnpVdU5qVTFMREl5Tmk0ME9UTXNNemMxTGpZMU5Yb2lMejROQ2drSlBDOW5QZzBLQ1R3dlp6NE5DZ2s4Wno0TkNnazhMMmMrRFFvSlBHYytEUW9KUEM5blBnMEtDVHhuUGcwS0NUd3ZaejROQ2drOFp6NE5DZ2s4TDJjK0RRb0pQR2MrRFFvSlBDOW5QZzBLQ1R4blBnMEtDVHd2Wno0TkNnazhaejROQ2drOEwyYytEUW9KUEdjK0RRb0pQQzluUGcwS0NUeG5QZzBLQ1R3dlp6NE5DZ2s4Wno0TkNnazhMMmMrRFFvSlBHYytEUW9KUEM5blBnMEtDVHhuUGcwS0NUd3ZaejROQ2drOFp6NE5DZ2s4TDJjK0RRb0pQR2MrRFFvSlBDOW5QZzBLQ1R4blBnMEtDVHd2Wno0TkNqd3ZaejROQ2p3dmMzWm5QZz09In0=";

            address Chibyke = makeAddr("Chibyke");

            function setUp() public {
                deployer = new DeployFaceNft();
                faceNft = deployer.run();
            }

            // >-----FaceNft Tests-----<

            // This particular test helped me get the tokenURIs of all the Faces
            function testCanViewTokenURI() public {
                vm.prank(Chibyke);

                faceNft.mintNft();

                console2.log(faceNft.tokenURI(0));
            }

            function testConfirmFirstMintIsNerd() public {
                vm.prank(Chibyke);
                faceNft.mintNft();

                assert(keccak256(abi.encodePacked(faceNft.tokenURI(0))) == keccak256(abi.encodePacked(NERD_FACE_TOKEN_URI)));
            }

            function testCanMintAndHaveBalance() public {
                vm.prank(Chibyke);
                faceNft.mintNft();

                assert(faceNft.balanceOf(Chibyke) == 1);
            }

            function testFlipFaceToNerd() public {
                vm.startPrank(Chibyke);
                faceNft.mintNft();
                faceNft.flipFaceToNerd(0);
                vm.stopPrank();

                assert(keccak256(abi.encodePacked(faceNft.tokenURI(0))) == keccak256(abi.encodePacked(NERD_FACE_TOKEN_URI)));
            }

            function testFlipFaceToNinja() public {
                vm.startPrank(Chibyke);
                faceNft.mintNft();
                faceNft.flipFaceToNinja(0);
                vm.stopPrank();

                assert(keccak256(abi.encodePacked(faceNft.tokenURI(0))) == keccak256(abi.encodePacked(NINJA_FACE_TOKEN_URI)));
            }

            function testFlipFaceToSmile() public {
                vm.startPrank(Chibyke);
                faceNft.mintNft();
                faceNft.flipFaceToSmile(0);
                vm.stopPrank();

                assert(keccak256(abi.encodePacked(faceNft.tokenURI(0))) == keccak256(abi.encodePacked(SMILE_FACE_TOKEN_URI)));
            }
        }
    ```

  - ### Interactions.s.sol
    ```solidity
        // SPDX-License-Identifier: SEE LICENSE IN LICENSE
        pragma solidity >= 0.8.0;

        import {Script} from "forge-std/Script.sol";
        import {DevOpsTools} from "lib/Foundry-devops/src/DevOpsTools.sol";
        import {FaceNft} from "../src/FaceNft.sol";

        contract MintFaceNft is Script {
            string public constant NERD_FACE_TOKEN_URI =
                "data:application/json;base64,eyJuYW1lIjoiRmFjZSBORlQiLCAiZGVzY3JpcHRpb24iOiJGYWNlIE5GVCB0aGF0IHJlcHJlc2VudHMgdGhlIHBlcnNvbmFsaXR5IG9mIHRoZSBvd25lci4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiVHlwZSIsICJ2YWx1ZSI6ICJTdmcgSW1hZ2UifSwgeyJ0cmFpdF90eXBlIjogIlBlcnNvbmFsaXR5IiwgInZhbHVlIjogIjEwMCUifSwgImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpT0RBd2NIZ2lJR2hsYVdkb2REMGlPREF3Y0hnaUlIWnBaWGRDYjNnOUlqQWdNQ0EyTkNBMk5DSWdlRzFzYm5NOUltaDBkSEE2THk5M2QzY3Vkek11YjNKbkx6SXdNREF2YzNabklpQjRiV3h1Y3pwNGJHbHVhejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TVRrNU9TOTRiR2x1YXlJZ1lYSnBZUzFvYVdSa1pXNDlJblJ5ZFdVaUlISnZiR1U5SW1sdFp5SWdZMnhoYzNNOUltbGpiMjVwWm5rZ2FXTnZibWxtZVMwdFpXMXZhbWx2Ym1VdGJXOXViM1J2Ym1VaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVdSWlRXbGtJRzFsWlhRaVBqeHdZWFJvSUdROUlrMHpNaUF5UXpFMUxqUXpNaUF5SURJZ01UVXVORE15SURJZ016SnpNVE11TkRNeUlETXdJRE13SURNd2N6TXdMVEV6TGpRek1pQXpNQzB6TUZNME9DNDFOamdnTWlBek1pQXliVEU0TGpFd015QTVMak15TkdFeE5pNDBNVGdnTVRZdU5ERTRJREFnTUNBd0xUZ3VPVGM1TFM0NU1UVmpMUzQzTURNdU1UTTFMUzR4T1RJZ01pNHlOeTR6T0RnZ01pNHhOVFpqTkM0eE5qZ3RMamMwT0NBNExqUTFOaTQwSURFeExqWTVJRE11TVRNell5NHhOak11TVRReUxqUTJPUzR3TVRVdU56WTFMUzR5TWpKaE1qY3VORGt4SURJM0xqUTVNU0F3SURBZ01TQTBMakEySURjdU5qWkROVFV1TnpNZ01Ua3VORFUySURVeExqWTFOeUF4TnlBME55QXhOMk10TkM0MU16TWdNQzA0TGpVeU1TQXlMak15TXkweE1DNDRORGdnTlM0NE5ESmpMVEl1TmpnNExURXVNVFk0TFRVdU9EQTFMVEV1TURZeExUZ3VNekF4TGpBd04wTXlOUzQxTWpVZ01Ua3VNekkySURJeExqVXpOeUF4TnlBeE55QXhOMk10TkM0Mk5UY2dNQzA0TGpjeklESXVORFUzTFRFeExqQXlOaUEyTGpFek4yRXlOeTQwTmpnZ01qY3VORFk0SURBZ01DQXhJRFF1TVRNMkxUY3VOelU0WXk0eU55NHhPVGN1TlRNNExqSTVPUzQyT0RZdU1UWTVZVEUwTGpJek15QXhOQzR5TXpNZ01DQXdJREVnTVRFdU5qa3lMVE11TVRNell5NDFPQzR4TVRNZ01TNHdPVEl0TWk0d01qRXVNemc1TFRJdU1UVTJZVEUyTGpReE1TQXhOaTQwTVRFZ01DQXdJREF0T0M0Mk56SXVPRU14T1M0d01EWWdOaTQ1TnpNZ01qVXVNakU0SURRdU5TQXpNaUEwTGpWak5pNDVNamdnTUNBeE15NHlOaklnTWk0MU9ERWdNVGd1TVRBeklEWXVPREkwVFRVM0lETXdZekFnTlM0MU1qRXROQzQwTnprZ01UQXRNVEFnTVRCekxURXdMVFF1TkRjNUxURXdMVEV3WXpBdE5TNDFNalFnTkM0ME56a3RNVEFnTVRBdE1UQnpNVEFnTkM0ME56WWdNVEFnTVRCdExUSTVMams1T1NBd1l6QWdOUzQxTWpNdE5DNDBOemtnTVRBdE1UQXVNREF4SURFd1l5MDFMalV5TWlBd0xURXdMVFF1TkRjM0xURXdMVEV3WXpBdE5TNDFNalFnTkM0ME56Y3RNVEFnTVRBdE1UQnpNVEF1TURBeElEUXVORGMySURFd0xqQXdNU0F4TUUwek1pQTFPUzQxWXkweE5DNDFOak1nTUMweU5pNDFNVEV0TVRFdU16YzVMVEkzTGpRek5pMHlOUzQzTVRKRE5pNHhPRGNnTXprdU1URTVJREV4TGpFek9TQTBNeUF4TnlBME0yTTNMakU0SURBZ01UTXROUzQ0TWlBeE15MHhNMk13TFRFdU1qYzJMUzR4T1RFdE1pNDFNRFl0TGpVek5DMHpMalkzTVdNeExqVXpMUzQwTXpZZ015NDFOQzB1TkRNMElEVXVNRFk0TGpBd01VRXhNaTQ1TmpRZ01USXVPVFkwSURBZ01DQXdJRE0wSURNd1l6QWdOeTR4T0NBMUxqZ3lJREV6SURFeklERXpZelV1T0RZeElEQWdNVEF1T0RFekxUTXVPRGd4SURFeUxqUXpOaTA1TGpJeE1rTTFPQzQxTVRFZ05EZ3VNVEl4SURRMkxqVTJNeUExT1M0MUlETXlJRFU1TGpVaUlHWnBiR3c5SWlNd01EQXdNREFpUGp3dmNHRjBhRDQ4Wld4c2FYQnpaU0JqZUQwaU1qQWlJR041UFNJek1DNDFJaUJ5ZUQwaU5DSWdjbms5SWpVaUlHWnBiR3c5SWlNd01EQXdNREFpUGp3dlpXeHNhWEJ6WlQ0OFpXeHNhWEJ6WlNCamVEMGlORFFpSUdONVBTSXpNQzQxSWlCeWVEMGlOQ0lnY25rOUlqVWlJR1pwYkd3OUlpTXdNREF3TURBaVBqd3ZaV3hzYVhCelpUNDhjR0YwYUNCa1BTSk5OREV1TkRBMElEUTFMakUxWXkwekxqSXlNeUF5TGpJMk9TMDRMak0xTXlBekxqZ3pOQzB4TXk0Mk5pQXlMalF6TTJNdE1TNDBNakV0TGpNM055MHlMalV6TlNBekxqTXhMVEV1TURFNElETXVOek16WXpVdU56WTNJREV1TlRVZ01USXVNRFE1TGpReU9TQXhOaTQ1TXkwekxqQXhOR014TGpJd05TMHVPRFk0TFRFdU1EVTBMVFF1TURJM0xUSXVNalV5TFRNdU1UVXlJaUJtYVd4c1BTSWpNREF3TURBd0lqNDhMM0JoZEdnK1BDOXpkbWMrIn0=";
            string public constant NINJA_FACE_TOKEN_URI =
                "data:application/json;base64,eyJuYW1lIjoiRmFjZSBORlQiLCAiZGVzY3JpcHRpb24iOiJGYWNlIE5GVCB0aGF0IHJlcHJlc2VudHMgdGhlIHBlcnNvbmFsaXR5IG9mIHRoZSBvd25lci4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiVHlwZSIsICJ2YWx1ZSI6ICJTdmcgSW1hZ2UifSwgeyJ0cmFpdF90eXBlIjogIlBlcnNvbmFsaXR5IiwgInZhbHVlIjogIjEwMCUifSwgImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpT0RBd2NIZ2lJR2hsYVdkb2REMGlPREF3Y0hnaUlIWnBaWGRDYjNnOUlqQWdNQ0ExTVRJZ05URXlJaUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQanh3WVhSb0lHWnBiR3c5SWlNd01EQXdNREFpSUdROUlrMHlPREF1TURVMElERTVMamcyTjJNdE5qUXVNekUxSURBdE1USXhMamMySURJNExqYzVNeTB4TlRrdU5qUXpJRGN6TGprek5DQXlOeTR6T0RjdU1EY2dPRGN1T1RJNElETXVNRFVnT1RZdU1USWdNalV1TnpJMkxUTTRMalF4TkMweE1pNHhNRFV0TnprdU56VXpMVEV4TGpJMkxURXdPQzQxTXpRdE9TNHpNREpoTWpBeExqQXhNeUF5TURFdU1ERXpJREFnTUNBd0xURXpMalkxTmlBeU15NHpNVFJqTXpFdU5UQTNMVGd1TXpBM0lERTBOeTQ1T1RndE15NHpOeUF4TlRRdU9DQXlNUzR5TmpndE56VXVPVGcxTFRFNExqWXlOQzB4TkRBdU5Ua3RPQzQyTlMweE5qSXVNRFU0TFRRdU9EazFMVGd1TnpZNElESXlMalEwTmkweE15NDFPRFFnTkRZdU9EQTFMVEV6TGpVNE5DQTNNaTR5TnpJZ01DQXhNVEV1TnpNMklEazJMakkwT0NBeU5qa3VPVFE1SURJeE1DNHpNalFnTWpZNUxqazBPU0ExTnk0NE1EZ2dNQ0F4TURrdU1TMDBNQzQyTXlBeE5EVXVOak0zTFRrMUxqSTBPQzB6TVM0ME1ETWdNak11T0RFeUxUazRMakEwSURVM0xqTXdPQzB4TXprdU1EQXlJRE0wTGpZME9DQTRNUzQxT1RJdE9DNDVPVFFnTVRNNUxqazJOUzAxTUM0NU56Z2dNVFUyTGpFNUxUWXpMak0xTXlBeU5TNHlNRGN0TkRjdU1UUXlJRE01TGprMU9TMHhNREF1TkRNeUlETTVMamsxT1MweE5EVXVPVGsySURBdE1URXhMamN6TnkwNU1pNDBOemN0TWpBeUxqTXhOeTB5TURZdU5UVXpMVEl3TWk0ek1UZDZiUzB1TURBeUlERTFNUzQyT1RKak1UQTFMakE0TkNBd0lERTVNQzR5TnpNZ01qY3VOekkzSURFNU1DNHlOek1nTmpFdU9UTXhJREFnTWpJdU1EUTNMVFF1TkRrMUlETXpMalE0TFRVM0xqYzVOeUEwTkM0ME5UTXRNamt1TXprZ05pNHdOVEl0T1RVdU1USTNMVE14TGpFNE1TMHhNekl1TkRjMkxUTXhMakU0TVMwek5DNDROalFnTUMwNE55NHhNaUEwTVM0ek5EVXRNVEUxTGpJeE9TQXpOaTR3TVRjdE5UWXVOVGszTFRFd0xqY3pNaTAzTlM0d05UTXRNall1TkRNekxUYzFMakExTXkwME9TNHlPRGtnTUMwek5DNHlNRFFnT0RVdU1UZzRMVFl4TGprek1TQXhPVEF1TWpjeUxUWXhMamt6TVhwdE9ETXVPRGcxSURNNUxqZzVOR010TWpBdU1UUXRMakV5TFRReExqVTNNU0F6TGpJNU5TMDBNUzQwTnpVZ09TNDVNUzR4T0RJZ01USXVORFV6SURFM0xqTTJOQ0F5TWk0eU9UZ2dNemd1TXpjM0lESXhMams1SURJeExqQXhNeTB1TXpBMklERTRMalUxTlMweE5pNHlNVFlnTXpjdU56RTNMVEl6TGpFd01TMHVNRGcxTFRVdU9ETTNMVEUyTGpnMUxUZ3VOamt6TFRNMExqWXlMVGd1TnprNWVtMHRNVGN5TGpZNE1pQXlMamc0TTJNdE1UY3VOemN1TVRBMUxUTTBMalV6TkNBeUxqazJOQzB6TkM0Mk1pQTRMamdnTVRrdU1UWXlJRFl1T0RnMUlERTJMamN3TkNBeU1pNDNPVFlnTXpjdU56RTRJREl6TGpFd01pQXlNUzR3TVRNdU16QTNJRE00TGpFNU5TMDVMalUwSURNNExqTTNOeTB5TVM0NU9USXVNRGsyTFRZdU5qRTFMVEl4TGpNek5pMHhNQzR3TXkwME1TNDBOelV0T1M0NU1YcHRPVEl1TlRjZ09ESXVORFF4WXpNeExqQXpNaUF3SURVMkxqRTRPQ0F5TlM0eU16VWdOVFl1TVRnNElESTFMakl6TlhNdE1qZ3VNVGcwTFRFeExqRXdOQzAxT1M0eU1UY3RNVEV1TVRBMFl5MHpNUzR3TXpJZ01DMDFNeTR4TmlBeE1TNHhNRFF0TlRNdU1UWWdNVEV1TVRBMGN6STFMakUxTmkweU5TNHlNelVnTlRZdU1Ua3RNalV1TWpNMWVrMHpNUzR5TlNBME1URXVNemxqTkM0ek5EUWdNaTR3TkRZZ055NDNPRE10TkRBdU16TTJJRFV5TGpJME5pMDJNUzR5TmpVdE9DNHhNVEV0T0M0ME5qVXRNVEl1TkRNNExUSTBMall6T0MweE5DNHlOQzB6TlM0MU1ESXRNekl1TnpNeklEUXVNVFU0TFRVMUxqQXhNaUE0TkM0NE9EY3RNemd1TURBMklEazJMamMyTjNwdE5UWXVNekV0TkRFdU5qazBZeTAzTGpVeE1TMHVNRFV5TFRFM0xqSTJMUzR5TWpndE1UY3VORFExSURFMkxqa3pOeTB1TkRrNElEUTJMak14TFRReUxqZ3dOU0E1Tmk0NU5UTXROREF1TVRJNElEazRMakl4TlNBM0xqRXpPQ0F6TGpNMk5DQTBPUzQxT1RndE16SXVNRGMzSURZeExqa3dOaTAxT1M0ME5DQTBMakUxT1MwNUxqSTBOQ0F4TVM0MU1UWXROVFV1TmpBekxUUXVNek16TFRVMUxqY3hNbm9pTHo0OEwzTjJaejQ9In0=";
            string public constant SMILE_FACE_TOKEN_URI =
                "data:application/json;base64,eyJuYW1lIjoiRmFjZSBORlQiLCAiZGVzY3JpcHRpb24iOiJGYWNlIE5GVCB0aGF0IHJlcHJlc2VudHMgdGhlIHBlcnNvbmFsaXR5IG9mIHRoZSBvd25lci4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiVHlwZSIsICJ2YWx1ZSI6ICJTdmcgSW1hZ2UifSwgeyJ0cmFpdF90eXBlIjogIlBlcnNvbmFsaXR5IiwgInZhbHVlIjogIjEwMCUifSwgImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCb1pXbG5hSFE5SWpnd01IQjRJaUIzYVdSMGFEMGlPREF3Y0hnaUlIWmxjbk5wYjI0OUlqRXVNU0lnYVdROUlrTmhjR0ZmTVNJZ2VHMXNibk05SW1oMGRIQTZMeTkzZDNjdWR6TXViM0puTHpJd01EQXZjM1puSWlCNGJXeHVjenA0YkdsdWF6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNVGs1T1M5NGJHbHVheUlnRFFvSklIWnBaWGRDYjNnOUlqQWdNQ0EwTlRJdU9UZzJJRFExTWk0NU9EWWlJSGh0YkRwemNHRmpaVDBpY0hKbGMyVnlkbVVpUGcwS1BHYytEUW9KUEdjK0RRb0pDVHhuUGcwS0NRa0pQSEJoZEdnZ2MzUjViR1U5SW1acGJHdzZJekF4TURBd01qc2lJR1E5SWsweU1qWXVORGt6TERCRE1UQXhMalUzTnl3d0xEQXNNVEF4TGpVM055d3dMREl5Tmk0ME9UTmpNQ3d4TWpRdU9EY3pMREV3TVM0MU56Y3NNakkyTGpRNU15d3lNall1TkRrekxESXlOaTQwT1RNTkNna0pDUWxqTVRJMExqZzFNaXd3TERJeU5pNDBPVE10TVRBeExqWXlMREl5Tmk0ME9UTXRNakkyTGpRNU0wTTBOVEl1T1RnMkxERXdNUzQxTnpjc016VXhMak0wTlN3d0xESXlOaTQwT1RNc01Ib2dUVEl5Tmk0ME9UTXNOREkzTGpjNU1nMEtDUWtKQ1dNdE1URXhMakEwTml3d0xUSXdNUzR6TWkwNU1DNHlPVFV0TWpBeExqTXlMVEl3TVM0eU9UbGpNQzB4TVRFdU1ESTFMRGt3TGpJM05DMHlNREV1TXpReUxESXdNUzR6TWkweU1ERXVNelF5WXpFeE1DNDVPRElzTUN3eU1ERXVNamMzTERrd0xqTXhOeXd5TURFdU1qYzNMREl3TVM0ek5ESU5DZ2tKQ1FsRE5ESTNMamMzTERNek55NDBPVFlzTXpNM0xqUTNOU3cwTWpjdU56a3lMREl5Tmk0ME9UTXNOREkzTGpjNU1ub2lMejROQ2drSkNUeHdZWFJvSUhOMGVXeGxQU0ptYVd4c09pTXdNVEF3TURJN0lpQmtQU0pOTVRRM0xqSTROU3d5TWpJdU5UQXpZekUyTGpneU5Td3dMRE13TGpRMU9DMHhNeTQxTkRZc016QXVORFU0TFRNd0xqTTFZekF0TVRZdU9EQTBMVEV6TGpZek15MHpNQzR6T1RNdE16QXVORFU0TFRNd0xqTTVNdzBLQ1FrSkNXTXRNVFl1TnpFM0xEQXRNekF1TXprekxERXpMalU1TFRNd0xqTTVNeXd6TUM0ek9UTlRNVE13TGpVMk9Dd3lNakl1TlRBekxERTBOeTR5T0RVc01qSXlMalV3TTNvaUx6NE5DZ2tKQ1R4amFYSmpiR1VnYzNSNWJHVTlJbVpwYkd3Nkl6QXhNREF3TWpzaUlHTjRQU0l6TURVdU5qTTJJaUJqZVQwaU1Ua3lMakV6TVNJZ2NqMGlNekF1TXpjeUlpOCtEUW9KQ1FrOGNHRjBhQ0J6ZEhsc1pUMGlabWxzYkRvak1ERXdNREF5T3lJZ1pEMGlUVEl5Tmk0ME9UTXNNemMxTGpZMU5XTTJNQzR6T1Rnc01Dd3hNVEl1TURFM0xUTTJMakE0T0N3eE16VXVOVEE0TFRnM0xqYzNNa2c1TVM0d01EY05DZ2tKQ1FsRE1URTBMalF4TVN3ek16a3VOVFkzTERFMk5pNHdNeXd6TnpVdU5qVTFMREl5Tmk0ME9UTXNNemMxTGpZMU5Yb2lMejROQ2drSlBDOW5QZzBLQ1R3dlp6NE5DZ2s4Wno0TkNnazhMMmMrRFFvSlBHYytEUW9KUEM5blBnMEtDVHhuUGcwS0NUd3ZaejROQ2drOFp6NE5DZ2s4TDJjK0RRb0pQR2MrRFFvSlBDOW5QZzBLQ1R4blBnMEtDVHd2Wno0TkNnazhaejROQ2drOEwyYytEUW9KUEdjK0RRb0pQQzluUGcwS0NUeG5QZzBLQ1R3dlp6NE5DZ2s4Wno0TkNnazhMMmMrRFFvSlBHYytEUW9KUEM5blBnMEtDVHhuUGcwS0NUd3ZaejROQ2drOFp6NE5DZ2s4TDJjK0RRb0pQR2MrRFFvSlBDOW5QZzBLQ1R4blBnMEtDVHd2Wno0TkNqd3ZaejROQ2p3dmMzWm5QZz09In0=";

            function run() external {
                address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FaceNft", block.chainid);
                mintFaceOnContract(mostRecentlyDeployed);
            }

            function mintFaceOnContract(address faceNftAddress) public {
                vm.startBroadcast();
                FaceNft(faceNftAddress).mintNft();
                vm.stopBroadcast();
            }
        }
    ```

  - ### TestDeploy.t.sol
    ```solidity
        // SPDX-License-Identifier: SEE LICENSE IN LICENSE
        pragma solidity >= 0.8.0;

        import {Test, console2} from "forge-std/Test.sol";
        import {DeployFaceNft} from "../script/DeployFaceNft.s.sol";

        contract TestDeploy is Test {
            DeployFaceNft public deployer;

            function setUp() public {
                deployer = new DeployFaceNft();
            }

            function testConvertSvgToUri() public view {
                string memory expectedUri =
                    "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCA2NCA2NCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgYXJpYS1oaWRkZW49InRydWUiIHJvbGU9ImltZyIgY2xhc3M9Imljb25pZnkgaWNvbmlmeS0tZW1vamlvbmUtbW9ub3RvbmUiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIG1lZXQiPjxwYXRoIGQ9Ik0zMiAyQzE1LjQzMiAyIDIgMTUuNDMyIDIgMzJzMTMuNDMyIDMwIDMwIDMwczMwLTEzLjQzMiAzMC0zMFM0OC41NjggMiAzMiAybTE4LjEwMyA5LjMyNGExNi40MTggMTYuNDE4IDAgMCAwLTguOTc5LS45MTVjLS43MDMuMTM1LS4xOTIgMi4yNy4zODggMi4xNTZjNC4xNjgtLjc0OCA4LjQ1Ni40IDExLjY5IDMuMTMzYy4xNjMuMTQyLjQ2OS4wMTUuNzY1LS4yMjJhMjcuNDkxIDI3LjQ5MSAwIDAgMSA0LjA2IDcuNjZDNTUuNzMgMTkuNDU2IDUxLjY1NyAxNyA0NyAxN2MtNC41MzMgMC04LjUyMSAyLjMyMy0xMC44NDggNS44NDJjLTIuNjg4LTEuMTY4LTUuODA1LTEuMDYxLTguMzAxLjAwN0MyNS41MjUgMTkuMzI2IDIxLjUzNyAxNyAxNyAxN2MtNC42NTcgMC04LjczIDIuNDU3LTExLjAyNiA2LjEzN2EyNy40NjggMjcuNDY4IDAgMCAxIDQuMTM2LTcuNzU4Yy4yNy4xOTcuNTM4LjI5OS42ODYuMTY5YTE0LjIzMyAxNC4yMzMgMCAwIDEgMTEuNjkyLTMuMTMzYy41OC4xMTMgMS4wOTItMi4wMjEuMzg5LTIuMTU2YTE2LjQxMSAxNi40MTEgMCAwIDAtOC42NzIuOEMxOS4wMDYgNi45NzMgMjUuMjE4IDQuNSAzMiA0LjVjNi45MjggMCAxMy4yNjIgMi41ODEgMTguMTAzIDYuODI0TTU3IDMwYzAgNS41MjEtNC40NzkgMTAtMTAgMTBzLTEwLTQuNDc5LTEwLTEwYzAtNS41MjQgNC40NzktMTAgMTAtMTBzMTAgNC40NzYgMTAgMTBtLTI5Ljk5OSAwYzAgNS41MjMtNC40NzkgMTAtMTAuMDAxIDEwYy01LjUyMiAwLTEwLTQuNDc3LTEwLTEwYzAtNS41MjQgNC40NzctMTAgMTAtMTBzMTAuMDAxIDQuNDc2IDEwLjAwMSAxME0zMiA1OS41Yy0xNC41NjMgMC0yNi41MTEtMTEuMzc5LTI3LjQzNi0yNS43MTJDNi4xODcgMzkuMTE5IDExLjEzOSA0MyAxNyA0M2M3LjE4IDAgMTMtNS44MiAxMy0xM2MwLTEuMjc2LS4xOTEtMi41MDYtLjUzNC0zLjY3MWMxLjUzLS40MzYgMy41NC0uNDM0IDUuMDY4LjAwMUExMi45NjQgMTIuOTY0IDAgMCAwIDM0IDMwYzAgNy4xOCA1LjgyIDEzIDEzIDEzYzUuODYxIDAgMTAuODEzLTMuODgxIDEyLjQzNi05LjIxMkM1OC41MTEgNDguMTIxIDQ2LjU2MyA1OS41IDMyIDU5LjUiIGZpbGw9IiMwMDAwMDAiPjwvcGF0aD48ZWxsaXBzZSBjeD0iMjAiIGN5PSIzMC41IiByeD0iNCIgcnk9IjUiIGZpbGw9IiMwMDAwMDAiPjwvZWxsaXBzZT48ZWxsaXBzZSBjeD0iNDQiIGN5PSIzMC41IiByeD0iNCIgcnk9IjUiIGZpbGw9IiMwMDAwMDAiPjwvZWxsaXBzZT48cGF0aCBkPSJNNDEuNDA0IDQ1LjE1Yy0zLjIyMyAyLjI2OS04LjM1MyAzLjgzNC0xMy42NiAyLjQzM2MtMS40MjEtLjM3Ny0yLjUzNSAzLjMxLTEuMDE4IDMuNzMzYzUuNzY3IDEuNTUgMTIuMDQ5LjQyOSAxNi45My0zLjAxNGMxLjIwNS0uODY4LTEuMDU0LTQuMDI3LTIuMjUyLTMuMTUyIiBmaWxsPSIjMDAwMDAwIj48L3BhdGg+PC9zdmc+";

                string memory svg =
                    '<svg width="800px" height="800px" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class="iconify iconify--emojione-monotone" preserveAspectRatio="xMidYMid meet"><path d="M32 2C15.432 2 2 15.432 2 32s13.432 30 30 30s30-13.432 30-30S48.568 2 32 2m18.103 9.324a16.418 16.418 0 0 0-8.979-.915c-.703.135-.192 2.27.388 2.156c4.168-.748 8.456.4 11.69 3.133c.163.142.469.015.765-.222a27.491 27.491 0 0 1 4.06 7.66C55.73 19.456 51.657 17 47 17c-4.533 0-8.521 2.323-10.848 5.842c-2.688-1.168-5.805-1.061-8.301.007C25.525 19.326 21.537 17 17 17c-4.657 0-8.73 2.457-11.026 6.137a27.468 27.468 0 0 1 4.136-7.758c.27.197.538.299.686.169a14.233 14.233 0 0 1 11.692-3.133c.58.113 1.092-2.021.389-2.156a16.411 16.411 0 0 0-8.672.8C19.006 6.973 25.218 4.5 32 4.5c6.928 0 13.262 2.581 18.103 6.824M57 30c0 5.521-4.479 10-10 10s-10-4.479-10-10c0-5.524 4.479-10 10-10s10 4.476 10 10m-29.999 0c0 5.523-4.479 10-10.001 10c-5.522 0-10-4.477-10-10c0-5.524 4.477-10 10-10s10.001 4.476 10.001 10M32 59.5c-14.563 0-26.511-11.379-27.436-25.712C6.187 39.119 11.139 43 17 43c7.18 0 13-5.82 13-13c0-1.276-.191-2.506-.534-3.671c1.53-.436 3.54-.434 5.068.001A12.964 12.964 0 0 0 34 30c0 7.18 5.82 13 13 13c5.861 0 10.813-3.881 12.436-9.212C58.511 48.121 46.563 59.5 32 59.5" fill="#000000"></path><ellipse cx="20" cy="30.5" rx="4" ry="5" fill="#000000"></ellipse><ellipse cx="44" cy="30.5" rx="4" ry="5" fill="#000000"></ellipse><path d="M41.404 45.15c-3.223 2.269-8.353 3.834-13.66 2.433c-1.421-.377-2.535 3.31-1.018 3.733c5.767 1.55 12.049.429 16.93-3.014c1.205-.868-1.054-4.027-2.252-3.152" fill="#000000"></path></svg>';

                string memory actualUri = deployer.svgToImageURI(svg);

                console2.log(actualUri);

                assert(keccak256(abi.encode(actualUri)) == keccak256(abi.encode(expectedUri)));
            }
        }
    ```

# 15/07/2024 1.1

Deployed new contract on EThereum Sepolia with the following details:
  - Contract Address: 0x186A83894d8d6BaDB6fed08Fd4e534FC07227aFD
  - Chain: Ethereum Sepolia
  - Verification Status: `OK`
  - Minting Status: Suucessful in terminal, not loading on [Testnets OpenSea](https://testnets.opensea.io/) 