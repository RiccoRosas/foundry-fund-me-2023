// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMeV2} from "../../src/FundMeV2.sol";
import {DeployFundMeV2} from "../../script/DeployFundMeV2.s.sol";

contract FundMeV2Test is Test {
    FundMeV2 fundMeV2;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 420 ether;
    uint256 constant GAS_PRICE = 1;

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMeV2 deployFundMeV2 = new DeployFundMeV2();
        fundMeV2 = deployFundMeV2.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMeV2.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMeV2.getOwner());
        console.log(msg.sender);

        assertEq(fundMeV2.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMeV2.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //This command tells that the next function call should fail as expected (if it doesn't fail, the test fails)
        fundMeV2.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //Next tx will be sent from the homie USER :3
        fundMeV2.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMeV2.getAdressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMeV2.fund{value: SEND_VALUE}();

        address funder = fundMeV2.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMeV2.fund{value: SEND_VALUE}();
        _;
    } // we can add this modifier so we dont have to manually add funds to each test function

    function testOnlyownerCanWithdraw() public funded {
        vm.prank(USER);
        fundMeV2.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMeV2.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMeV2.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMeV2).balance;

        //Act

        vm.prank(fundMeV2.getOwner());
        fundMeV2.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMeV2.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMeV2).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //if you want to use numbers to make address, u gotta use uint160!!!
            hoax(address(i), SEND_VALUE);
            fundMeV2.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMeV2.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMeV2).balance;

        //Act
        vm.startPrank(fundMeV2.getOwner());
        fundMeV2.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMeV2).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMeV2.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //if you want to use numbers to make address, u gotta use uint160!!!
            hoax(address(i), SEND_VALUE);
            fundMeV2.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMeV2.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMeV2).balance;

        //Act
        vm.startPrank(fundMeV2.getOwner());
        fundMeV2.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMeV2).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMeV2.getOwner().balance
        );
    }
}

//Test Function Example//
/* function testDemo() public {
        console.log(number);
        console.log(
            "Good morning vietnam!!! Paranoid by Black Sabbath starts playing"
        );
        assertEq(number, 2);
    } 
*/
