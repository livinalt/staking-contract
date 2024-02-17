// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StakingContract {

    address owner;
    mapping(address => uint256) stakes;
    mapping(address => uint256) rewards;
    mapping(address => uint256) unlockTime;

    uint256 totalStakes;
    uint256 constant lockDuration = 30 ; // 
    uint256 stakingRate = 1;

    event Staked(address indexed staker, uint256 value);
    event Unstaked(address indexed staker, uint256 value);
    event RewardedCalculated(address indexed staker, uint256 value);

    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner
    }

    function stake(uint256 _value) external payable {
        uint256 amount = _value;
        require(amount > 0, "value must be greater than 0");
        
        stakes[msg.sender] += amount;
        totalStakes += amount;

        // Setting unlock time
        unlockTime[msg.sender] = block.timestamp + lockDuration; 

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 _value) external {
        require(_value > 0, "value must be greater than 0");
        require(stakes[msg.sender] >= _value, "Insufficient stakes");
        require(block.timestamp >= unlockTime[msg.sender], "Your staking period has not ended yet");

        stakes[msg.sender] -= _value;
        totalStakes -= _value;

        payable(msg.sender).transfer(_value);

        emit Unstaked(msg.sender, _value);
    }

    function calculateReward() external payable {
        uint256 rewardvalue = stakes[msg.sender] * stakingRate;
        rewards[msg.sender] += rewardvalue;

        emit RewardedCalculated(msg.sender, rewardvalue);
    }

    function withdrawRewards() external {
        require(block.timestamp >= unlockTime[msg.sender], "Your staking period is still active");
        uint256 rewardvalue = rewards[msg.sender];
        require(rewardvalue > 0, "No rewards to withdraw");

        rewards[msg.sender] = 0;
        
        payable(msg.sender).transfer(rewardvalue);
    }
    
}
