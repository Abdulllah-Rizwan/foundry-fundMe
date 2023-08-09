// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;
import {priceConvertor} from "./priceConvertor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe{

    using priceConvertor for uint;
    uint public constant MINIMUM_USD = 5e18;
    address[] private s_funders;
    mapping(address => uint) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    error FundMe__NotAnOwner();
    error FundMe__WidthdrawlFailure();

    modifier onlyOwner(){
        if(msg.sender!=i_owner) revert FundMe__NotAnOwner();
        _;
    }

    function fund() public payable {
        //ye neche msg.value jo h ye aesa a frist parameter jaega call krne k bad agar getConversion rate wale function m do parameters required hoty to msg.value.getConversionRate(sec argu) aese jata 
        require(msg.value.getConversionRate(s_priceFeed)>=MINIMUM_USD,"Didn't sent enough eath");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function widthdraw() onlyOwner public {
        uint fundersLength = s_funders.length;
        for(uint i=0;i<fundersLength;i++){
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool sent,) = payable (msg.sender).call{value:address(this).balance}("");
        if(!sent) revert FundMe__WidthdrawlFailure();
    }

    function getVersion() public view returns(uint){
        return s_priceFeed.version();
    }

    receive() external payable{
        fund();
    }

    fallback() external payable {
        fund();
    }

    // view / pure functions (Getters):

    function getAddressToAmountFunded(address fundingAddress) view external returns(uint){
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() view external returns(address){
        return i_owner;
    }
    
}
