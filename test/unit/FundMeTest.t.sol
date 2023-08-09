// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {console,Test} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    
    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

    address USER = makeAddr("user");

    uint constant SEND_VALUE = 0.1 ether;
    uint constant INIT_BALANCE = 10 ether;
    uint constant GAS_PRICE = 1;

    
    function setUp() external {
        DeployFundMe newDeployeFundMe = new DeployFundMe();
        fundMe = newDeployeFundMe.run();
        vm.deal(USER, INIT_BALANCE);
    }

    function testMinimumUSDisFive() public {
        assertEq(fundMe.MINIMUM_USD(),5e18);
        console.log("Alhumdullillah for everything");
    }

    function testIfOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint version = fundMe.getVersion();
        assertEq(version,4);
    }

    function testFunctionFailsWithoutEnoughEth() public {
        vm.expectRevert(); //tells whatever after this should fail
        fundMe.fund();
    }

    function testFundUpdates() public {
        vm.prank(USER); 
        
        fundMe.fund{value:SEND_VALUE}(); // next TX call will be made by USER
        uint amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }

    function addsFundersToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    function onlyOwnerCanWidthdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.widthdraw();
    }

    function testWidthdrawWithASingleFunder() public {
        //ARRANGE
        uint initialOwnerBalace = fundMe.getOwner().balance;
        uint initialFundMeBalance = address(fundMe).balance;
        //ACT
        uint gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.widthdraw();
        uint gasEnd = gasleft();
        uint gasUsed = (gasStart-gasEnd)*tx.gasprice;
        console.log(gasUsed);
        //ASSERT
        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(endingOwnerBalance,initialFundMeBalance+initialOwnerBalace);
    }

    function testWidtdrawFromMultipleFunders() public {
        //ARRANGE
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        
        for(uint160 i = startingFunderIndex;i<numberOfFunders;i++){
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint initialOwnerBalance = fundMe.getOwner().balance;
        uint initialFundMeBalance = address(fundMe).balance;
        
        //ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.widthdraw();
        vm.stopPrank();

        //ASSERT
        assertEq(address(fundMe).balance,0);
        assertEq(fundMe.getOwner().balance,initialOwnerBalance+initialFundMeBalance);
    }

}