# Base Piggy Bank Plans

A smart contract built on **Base L2** that allows users to deposit **BaseSupply tokens** into fixed-term staking plans.  
Users can choose different lock periods (30 days, 90 days, or 12 months) and earn attractive APYs.  
Designed with fairness, transparency, and onchain trust in mind.

---

## ✨ Key Features
- **Token**: BaseSupply (`0xf3cdfbe745595bf8b9055764936329b6c157fd7d`)
- **Minimum deposit**: 15 BaseSupply
- **Maximum participants**: 1000 users (first come, first serve)
- **Staking Plans**:
  - 30 days → **51% APY**
  - 90 days → **92% APY**
  - 12 months → **241% APY**
- **No early withdrawal**: Funds are locked until the chosen plan ends.
- **Reward distribution**: Rewards are paid in BaseSupply from the contract pool.
- **Owner**: Can fund the reward pool only (no privileged withdrawals).

---

## 📜 Contract Overview
- Contract holds user deposits securely.
- Rewards are calculated based on selected plan’s APY and duration.
- Rewards + principal become available once lock period ends.
- Events are emitted for deposit and withdrawal actions for transparency.

---

## 🚀 Deployment Instructions

### 1. Clone Repository
```bash
git clone https://github.com/arawrdn/base-piggy-bank-plans.git
cd base-piggy-bank-plans
