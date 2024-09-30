// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BlumeLiquidStaking is ERC20, Ownable, ReentrancyGuard {
    IERC20 public blsToken;
    uint256 private s_totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    error BLS_AmountEqualOrLessToZero();
    error BLS_TokenTransferFailed();
    error BLS_InsufficientStakingBalance();

    constructor(address _blsTokenAddress) ERC20("Staked BLS", "stBLS") Ownable(msg.sender) {
        blsToken = IERC20(_blsTokenAddress);
    }

    function stake(uint256 _amount) external nonReentrant {
        if (_amount <= 0) {
            revert BLS_AmountEqualOrLessToZero();
        }

        bool success = blsToken.transferFrom(msg.sender, address(this), _amount);
        if (!success) {
            revert BLS_TokenTransferFailed();
        }

        uint256 stBlsToMint = _amount;
        if (totalSupply() > 0) {
            stBlsToMint = (_amount * totalSupply()) / s_totalStaked;
        }

        _mint(msg.sender, stBlsToMint);
        s_totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external nonReentrant {
        if (_amount <= 0) {
            revert BLS_AmountEqualOrLessToZero();
        }

        if (balanceOf(msg.sender) < _amount) {
            revert BLS_InsufficientStakingBalance();
        }

        uint256 blsToReturn = (_amount * s_totalStaked) / totalSupply();

        _burn(msg.sender, _amount);
        s_totalStaked -= blsToReturn;

        bool success = blsToken.transfer(msg.sender, blsToReturn);
        if (!success) {
            revert BLS_TokenTransferFailed();
        }

        emit Unstaked(msg.sender, blsToReturn);
    }

    function getTotalStaked() external view returns (uint256) {
        return s_totalStaked;
    }

    function getStakedBalance(address _account) external view returns (uint256) {
        return (balanceOf(_account) * s_totalStaked) / totalSupply();
    }
}
