// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMeV2} from "../../src/FundMeV2.sol";
import {DeployFundMeV2} from "../../script/DeployFundMeV2.s.sol";
import {FundFundMeV2, WithdrawFundMeV2} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMeV2 fundMeV2;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 420 ether;
    uint256 constant GAS_PRICE = 1;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMeV2 deploy = new DeployFundMeV2();
        fundMeV2 = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMeV2 fundFundMeV2 = new FundFundMeV2();
        fundFundMeV2.fundFundMeV2(address(fundMeV2));

        WithdrawFundMeV2 withdrawFundMeV2 = new WithdrawFundMeV2();
        withdrawFundMeV2.withdrawFundMeV2(address(fundMeV2));

        assert(address(fundMeV2).balance == 0);
    }
}
