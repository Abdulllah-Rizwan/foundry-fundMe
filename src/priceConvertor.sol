// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


library priceConvertor{
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price*1e10);
    }

    function getConversionRate(uint ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint){
        uint ethPrice = getPrice(priceFeed);
        uint ethPriceInUSD = (ethPrice*ethAmount)/1e18;
        return ethPriceInUSD;
    }

}