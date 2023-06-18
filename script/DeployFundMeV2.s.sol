//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMeV2} from "../src/FundMeV2.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMeV2 is Script {
    function run() external returns (FundMeV2) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMeV2 fundMeV2 = new FundMeV2(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMeV2;
    }
}
//Any code before startBroadcast() will be simulated on my puter and not on the blockchain
