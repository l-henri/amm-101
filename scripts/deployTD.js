// Deploying the TD somewhere
// To verify it on Etherscan:
// npx hardhat verify --network sepolia <address> <constructor arg 1> <constructor arg 2>

const hre = require("hardhat");
const Str = require('@supercharge/strings')

async function main() {
  // Deploying contracts
  const ERC20TD = await hre.ethers.getContractFactory("ERC20TD");
  const Evaluator = await hre.ethers.getContractFactory("Evaluator");
  const DummyToken = await hre.ethers.getContractFactory("DummyToken");
  const erc20 = await ERC20TD.deploy("TD-AMM-101","TD-AMM-101",0);
  const dummytoken = await DummyToken.deploy("dummyToken", "DTK",ethers.BigNumber.from("2000000000000000000000000000000"));

  await erc20.deployed();
  
  console.log(
    `ERC20TD deployed at  ${erc20.address}`
  );
  await dummytoken.deployed();
  console.log(
    `DummyToken deployed at ${dummytoken.address}`
  );
  uniswapV2FactoryAddress = "0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f"
	wethAddress = "0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6"
  const evaluator = await Evaluator.deploy(erc20.address, dummytoken.address, uniswapV2FactoryAddress, wethAddress)
  await evaluator.deployed();
  console.log(
    `Evaluator deployed at ${evaluator.address}`
  );


    // Setting the teacher
    await erc20.setTeacher(evaluator.address, true)

    // Setting random values
    randomSupplies = []
    randomTickers = []
    for (i = 0; i < 20; i++)
      {
      randomSupplies.push(Math.floor(Math.random()*1000000000))
      randomTickers.push(Str.random(5))
      // randomTickers.push(web3.utils.utf8ToBytes(Str.random(5)))
      // randomTickers.push(Str.random(5))
      }
  
    console.log(randomTickers)
    console.log(randomSupplies)
    // console.log(web3.utils)
    // console.log(type(Str.random(5)0)
    await evaluator.setRandomTickersAndSupply(randomSupplies, randomTickers);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
