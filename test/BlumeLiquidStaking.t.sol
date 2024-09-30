// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {BlumeLiquidStaking} from "../src/BlumeLiquidStaking.sol";
import {BLSToken} from "../src/BLSToken.sol";

contract BlumeLiquidStakingTest is Test {
    BlumeLiquidStaking public stakingContract;
    BLSToken public blsToken;
    address public owner;
    address public alice;
    address public bob;
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10 ** 18; // 1 million BLS

    function setUp() public {
        owner = address(this);
        alice = makeAddr("ALICE");
        bob = makeAddr("BOB");

        blsToken = new BLSToken();
        stakingContract = new BlumeLiquidStaking(address(blsToken));

        blsToken.mint(alice, 10000 * 10 ** 18);
        blsToken.mint(bob, 10000 * 10 ** 18);
    }

    function testInitialState() external view {
        assertEq(stakingContract.name(), "Staked BLS");
        assertEq(stakingContract.symbol(), "stBLS");
        assertEq(address(stakingContract.blsToken()), address(blsToken));
        assertEq(stakingContract.getTotalStaked(), 0);
    }

    function testStaking() public {
        uint256 stakeAmount = 1000 * 10 ** 18;
        vm.startPrank(alice);
        blsToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);
        vm.stopPrank();

        assertEq(stakingContract.getTotalStaked(), stakeAmount);
        assertEq(stakingContract.balanceOf(alice), stakeAmount);
        assertEq(blsToken.balanceOf(address(stakingContract)), stakeAmount);
    }

    function testUnstaking() public {
        uint256 stakeAmount = 1000 * 10 ** 18;
        vm.startPrank(alice);
        blsToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);

        uint256 unstakeAmount = 500 * 10 ** 18;
        stakingContract.unstake(unstakeAmount);
        vm.stopPrank();

        assertEq(stakingContract.getTotalStaked(), stakeAmount - unstakeAmount);
        assertEq(stakingContract.balanceOf(alice), unstakeAmount);
        assertEq(blsToken.balanceOf(address(stakingContract)), stakeAmount - unstakeAmount);
        assertEq(blsToken.balanceOf(alice), 10000 * 10 ** 18 - stakeAmount + unstakeAmount);
    }

    function testMultipleUsersStaking() public {
        uint256 aliceStake = 1000 * 10 ** 18;
        uint256 bobStake = 2000 * 10 ** 18;

        vm.prank(alice);
        blsToken.approve(address(stakingContract), aliceStake);
        vm.prank(alice);
        stakingContract.stake(aliceStake);

        vm.prank(bob);
        blsToken.approve(address(stakingContract), bobStake);
        vm.prank(bob);
        stakingContract.stake(bobStake);

        assertEq(stakingContract.getTotalStaked(), aliceStake + bobStake);
        assertEq(stakingContract.balanceOf(alice), aliceStake);
        assertEq(stakingContract.balanceOf(bob), bobStake);
    }

    function testGetStakedBalance() public {
        uint256 stakeAmount = 1000 * 10 ** 18;
        vm.startPrank(alice);
        blsToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);
        vm.stopPrank();

        assertEq(stakingContract.getStakedBalance(alice), stakeAmount);
    }

    function testStakingZeroAmount() public {
        vm.expectRevert(BlumeLiquidStaking.BLS_AmountEqualOrLessToZero.selector);
        stakingContract.stake(0);
    }

    function testUnstakingZeroAmount() public {
        vm.expectRevert(BlumeLiquidStaking.BLS_AmountEqualOrLessToZero.selector);
        stakingContract.unstake(0);
    }

    function testUnstakingMoreThanStaked() public {
        uint256 stakeAmount = 1000 * 10 ** 18;
        vm.startPrank(alice);
        blsToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);

        vm.expectRevert(BlumeLiquidStaking.BLS_InsufficientStakingBalance.selector);
        stakingContract.unstake(stakeAmount + 1);
        vm.stopPrank();
    }

    function testFuzzStaking(uint256 amount) public {
        vm.assume(amount > 0 && amount <= blsToken.balanceOf(alice));
        vm.startPrank(alice);
        blsToken.approve(address(stakingContract), amount);
        stakingContract.stake(amount);
        vm.stopPrank();

        assertEq(stakingContract.getTotalStaked(), amount);
        assertEq(stakingContract.balanceOf(alice), amount);
    }

    function testFuzzUnstaking(uint256 stakeAmount, uint256 unstakeAmount) public {
        vm.assume(stakeAmount > 0 && stakeAmount <= blsToken.balanceOf(alice));
        vm.assume(unstakeAmount > 0 && unstakeAmount <= stakeAmount);

        vm.startPrank(alice);
        blsToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);
        stakingContract.unstake(unstakeAmount);
        vm.stopPrank();

        assertEq(stakingContract.getTotalStaked(), stakeAmount - unstakeAmount);
        assertEq(stakingContract.balanceOf(alice), stakeAmount - unstakeAmount);
    }
}
