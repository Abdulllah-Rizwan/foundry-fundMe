// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

    HelperConfig helperConfig = new HelperConfig();
    address ethUSDPriceFed = helperConfig.activeNetworkConfig();

    //Deploy script m agar change kia h to test m bhe change krna hoga
    function run() external returns(FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUSDPriceFed);
        vm.stopBroadcast();
        return fundMe;
    }
}