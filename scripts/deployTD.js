const hre = require("hardhat");
const Str = require("@supercharge/strings");

async function main() {
  // Deploying contracts
  const ERC20TD = await hre.ethers.getContractFactory("ERC20TD");
  const Evaluator = await hre.ethers.getContractFactory("Evaluator");
  const DummyToken = await hre.ethers.getContractFactory("DummyToken");
  const ExerciceSol = await hre.ethers.getContractFactory("ExerciceSol");
  const MyToken = await hre.ethers.getContractFactory("MyToken");

  const erc20 = await ERC20TD.deploy("TD-AMM-101", "TD-AMM-101", 0);
  await erc20.deployed();
  console.log(`ERC20TD deployed at ${erc20.address}`);

  const dummytoken = await DummyToken.deploy(
    "dummyToken",
    "DTK",
    ethers.BigNumber.from("2000000000000000000000000000000")
  );
  await dummytoken.deployed();
  console.log(`DummyToken deployed at ${dummytoken.address}`);

  // Deploying ExerciceSol
  const exerciceSol = await ExerciceSol.deploy();
  await exerciceSol.deployed();
  console.log("ExerciceSol deployed at:", exerciceSol.address);

  // Deploying MyToken
  const myToken = await MyToken.deploy();
  await myToken.deployed();
  console.log("MyToken deployed at:", myToken.address);

  uniswapV2FactoryAddress = "0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f";
  wethAddress = "0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6";
  const evaluator = await Evaluator.deploy(
    erc20.address,
    dummytoken.address,
    uniswapV2FactoryAddress,
    wethAddress
  );
  await evaluator.deployed();
  console.log(`Evaluator deployed at ${evaluator.address}`);

  // Setting the teacher
  await erc20.setTeacher(evaluator.address, true);

  // Setting random values
  randomSupplies = [];
  randomTickers = [];
  for (i = 0; i < 20; i++) {
    randomSupplies.push(Math.floor(Math.random() * 1000000000));
    randomTickers.push(Str.random(5));
  }

  console.log(randomTickers);
  console.log(randomSupplies);
  await evaluator.setRandomTickersAndSupply(randomSupplies, randomTickers);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
