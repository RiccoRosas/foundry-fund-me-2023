// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMev2__NotOwner();

contract FundMeV2 {
    using PriceConverter for uint256;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "BROKE ALERT LMFAOOOOOO"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length; //this withdraw function is cheaper because it call s_funders.length once and then use a variable instead of calling it every time from storage
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed :(");
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            // this part resets how much each address has donated back to zero in the array
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        //call example//
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); //calls can return multiple variables //Using Call is the Recommened way to send tokens
        require(callSuccess, "Call failed :(");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMev2__NotOwner();
        } //this line uses a custom error. Its more gas efficent since it doesnt need to store the string data in the contract
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure Functions Also known at Getters
     */

    function getAdressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
//transfer example//
// - payable (msg.sender).transfer(address(this).balance);  // msg.sender = address | payable(msg.sender) = payable address

//send example//
// bool sendSuccess = payable(msg.sender).send(address(this).balance);
// require(sendSuccess, "Send Failed :(");
