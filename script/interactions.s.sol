// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script,console} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable (mostRecentDeployed)).fund{value:SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded fundMe with %s ",SEND_VALUE);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        fundFundMe(mostRecentDeployed);
    }
}

contract WidthdrawFundMe is Script {

    function widthdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).widthdraw();
        vm.stopBroadcast();
        console.log("widthdraw fundme balance");
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        widthdrawFundMe(mostRecentDeployed);
    }

}