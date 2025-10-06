// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BasePiggyBankPlans {
    IERC20 public immutable baseSupply;
    address public owner;

    uint256 public constant MIN_DEPOSIT = 15 * 1e18;
    uint256 public constant MAX_USERS = 1000;
    uint256 public totalUsers;

    struct Plan {
        uint256 duration; // in seconds
        uint256 apy;      // APY in percentage
    }

    struct DepositInfo {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 apy;
        bool claimed;
        bool active;
    }

    mapping(address => DepositInfo) public deposits;

    Plan[3] public plans;

    event Deposited(address indexed user, uint256 amount, uint256 planId);
    event Withdrawn(address indexed user, uint256 principal, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _baseSupply) {
        baseSupply = IERC20(_baseSupply);
        owner = msg.sender;

        // Setup plans
        plans[0] = Plan(30 days, 51);    // 30 days → 51% APY
        plans[1] = Plan(90 days, 92);    // 90 days → 92% APY
        plans[2] = Plan(365 days, 241);  // 12 months → 241% APY
    }

    function deposit(uint256 amount, uint8 planId) external {
        require(amount >= MIN_DEPOSIT, "Deposit must be >= 15 BaseSupply");
        require(planId < 3, "Invalid plan");

        DepositInfo storage info = deposits[msg.sender];
        require(!info.active, "Already deposited"); // 1 deposit per user

        if (!info.active) {
            require(totalUsers < MAX_USERS, "User limit reached");
            totalUsers++;
        }

        require(baseSupply.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        Plan memory plan = plans[planId];
        deposits[msg.sender] = DepositInfo({
            amount: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + plan.duration,
            apy: plan.apy,
            claimed: false,
            active: true
        });

        emit Deposited(msg.sender, amount, planId);
    }

    function withdraw() external {
        DepositInfo storage info = deposits[msg.sender];
        require(info.active, "No active deposit");
        require(!info.claimed, "Already withdrawn");
        require(block.timestamp >= info.endTime, "Lock period not ended");

        uint256 principal = info.amount;
        uint256 reward = _calculateReward(info);

        info.claimed = true;
        info.active = false;

        require(baseSupply.transfer(msg.sender, principal), "Principal transfer failed");

        uint256 contractBal = baseSupply.balanceOf(address(this));
        if (reward > 0 && reward <= contractBal) {
            require(baseSupply.transfer(msg.sender, reward), "Reward transfer failed");
        }

        emit Withdrawn(msg.sender, principal, reward);
    }

    function pendingReward(address user) external view returns (uint256) {
        DepositInfo memory info = deposits[user];
        if (!info.active || block.timestamp < info.endTime) return 0;
        return _calculateReward(info);
    }

    function _calculateReward(DepositInfo memory info) internal pure returns (uint256) {
        uint256 timeElapsed = info.endTime - info.startTime;
        uint256 reward = (info.amount * info.apy * timeElapsed) / (100 * 365 days);
        return reward;
    }

    function fundPool(uint256 amount) external onlyOwner {
        require(baseSupply.transferFrom(msg.sender, address(this), amount), "Fund transfer failed");
    }
}
