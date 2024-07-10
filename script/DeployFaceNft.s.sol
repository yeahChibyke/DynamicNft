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

        console2.log(nerdFaceSvg);
        console2.log(ninjaFaceSvg);
        console2.log(smileFaceSvg);

        string memory nerdFaceUri = svgToImageURI(nerdFaceSvg);
        string memory ninjaFaceUri = svgToImageURI(ninjaFaceSvg);
        string memory smileFaceUri = svgToImageURI(smileFaceSvg);

        console2.log(nerdFaceUri);
        console2.log(ninjaFaceUri);
        console2.log(smileFaceUri);

        vm.startBroadcast();
        FaceNft faceNft = new FaceNft(nerdFaceUri, ninjaFaceUri, smileFaceUri);
        vm.stopBroadcast();
        return faceNft;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg))) // Removing unnecessary type castings, this line can be resumed as follows : 'abi.encodePacked(svg)'
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
