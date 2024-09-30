//SPDX-License-Identifier:MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/script.sol";
import {BLSToken} from "../src/BLSToken.sol";
import {BlumeLiquidStaking} from "../src/BlumeLiquidStaking.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract StakeBLSToken is Script {
    uint private s_stakeAmount = 10e18;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "BlumeLiquidStaking",
            block.chainid
        );

        stake(mostRecentlyDeployed);
    }

    function stake(address contractAddress) public {
        vm.startBroadcast();
        BlumeLiquidStaking(contractAddress).stake(s_stakeAmount);
        vm.stopBroadcast();
    }
}

contract UnstakeBLSToken is Script {
    uint private s_unstakeAmount = 10e18;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "BlumeLiquidStaking",
            block.chainid
        );

        unstake(mostRecentlyDeployed);
    }

    function unstake(address contractAddress) public {
        vm.startBroadcast();
        BlumeLiquidStaking(contractAddress).unstake(s_unstakeAmount);
        vm.stopBroadcast();
    }
}
