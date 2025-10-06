const { ethers } = require("hardhat");

async function main() {
  // Replace with deployed contract address
  const piggyBankAddress = "YOUR_DEPLOYED_PIGGYBANK_ADDRESS";
  const baseSupplyAddress = "0xf3cdfbe745595bf8b9055764936329b6c157fd7d";

  const [user] = await ethers.getSigners();
  console.log("Using account:", user.address);

  // Attach contracts
  const BaseSupply = await ethers.getContractAt("IERC20", baseSupplyAddress);
  const PiggyBank = await ethers.getContractAt("BasePiggyBankPlans", piggyBankAddress);

  // Amount to deposit (15 BaseSupply minimum)
  const amount = ethers.utils.parseUnits("20", 18); // example: 20 tokens
  const planId = 0; // 0 = 30d, 1 = 90d, 2 = 12m

  // Step 1: Approve PiggyBank
  console.log("Approving PiggyBank to spend BaseSupply...");
  const approveTx = await BaseSupply.approve(piggyBankAddress, amount);
  await approveTx.wait();
  console.log("Approved!");

  // Step 2: Deposit
  console.log(`Depositing ${ethers.utils.formatUnits(amount, 18)} BaseSupply into plan ${planId}...`);
  const depositTx = await PiggyBank.deposit(amount, planId);
  await depositTx.wait();
  console.log("Deposit successful!");

  // Step 3: Check pending rewards (immediately should be very small)
  const pending = await PiggyBank.pendingReward(user.address);
  console.log("Pending reward (BaseSupply):", ethers.utils.formatUnits(pending, 18));

  // Step 4: Withdraw (for testing, only works after lock period)
  // const withdrawTx = await PiggyBank.withdraw();
  // await withdrawTx.wait();
  // console.log("Withdraw successful!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
