// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.8.0;

import {Script} from "forge-std/Script.sol";
import {DynamicPfp} from "../src/DynamicPfp.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployDynamicPfp is Script {
    function run() external returns (DynamicPfp) {
        string memory ogSvg = vm.readFile("./img/og.svg");
        string memory punkSvg = vm.readFile("./img/punk.svg");
        vm.startBroadcast();
        DynamicPfp dynamicPfp = new DynamicPfp(svgToImageURI(ogSvg), svgToImageURI(punkSvg));
        vm.stopBroadcast();
        return dynamicPfp;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg))) // Removing unnecessary type castings, this line can be resumed as follows : 'abi.encodePacked(svg)'
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
