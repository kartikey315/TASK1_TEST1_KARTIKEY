//SPDX-License-Identifier:MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/script.sol";
import {BLSToken} from "../src/BLSToken.sol";
import {BlumeLiquidStaking} from "../src/BlumeLiquidStaking.sol";

contract DeployBlumeLiquidStaking is Script {
    function run() external returns (BLSToken, BlumeLiquidStaking) {
        vm.startBroadcast();
        BLSToken blsToken = new BLSToken();
        BlumeLiquidStaking stakingContract = new BlumeLiquidStaking(
            address(blsToken)
        );
        vm.stopBroadcast();
        return (blsToken, stakingContract);
    }
}
