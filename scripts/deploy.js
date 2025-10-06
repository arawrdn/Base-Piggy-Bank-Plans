async function main() {
  const PiggyBank = await ethers.getContractFactory("BasePiggyBankPlans");
  const piggy = await PiggyBank.deploy("0xf3cdfbe745595bf8b9055764936329b6c157fd7d");
  await piggy.deployed();
  console.log("PiggyBank deployed to:", piggy.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
