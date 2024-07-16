// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import {FaceNft} from "../src/FaceNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployFaceNft is Script {
    function run() external returns (FaceNft) {
        string memory nerdFaceSvg = vm.readFile("../img/nerdFace.svg");
        string memory ninjaFaceSvg = vm.readFile("../img/ninjaFace.svg");
        string memory smileFaceSvg = vm.readFile("../img/smileFace.svg");

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
