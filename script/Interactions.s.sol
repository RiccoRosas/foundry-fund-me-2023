//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//Make a Fund script
//Make a Withdraw script
//I Cooka da Pizza

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMeV2} from "../src/FundMeV2.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMeV2 is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMeV2(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMeV2(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded FundMeV2 contract with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMeV2",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMeV2(mostRecentDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMeV2 is Script {
    function withdrawFundMeV2(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMeV2(payable(mostRecentDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMeV2",
            block.chainid
        );

        withdrawFundMeV2(mostRecentDeployed);
    }
}
