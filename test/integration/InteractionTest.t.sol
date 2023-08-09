// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {console,Test} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WidthdrawFundMe} from "../../script/interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract FundMeTestIntegration is Test {

    FundMe public fundMe;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER,STARTING_USER_BALANCE);
    }

     function testUserCanFundAndOwnerWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WidthdrawFundMe withdrawFundMe = new WidthdrawFundMe();
        withdrawFundMe.widthdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }


}