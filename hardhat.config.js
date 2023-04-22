const { mnemonic, infuraApiKey, etherscanApiKey } = require('./secrets.json');
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  networks: {
    hardhat: {
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${infuraApiKey}`,
      accounts: {
        mnemonic: mnemonic
      }
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${infuraApiKey}`,
      accounts: {
        mnemonic: mnemonic
      }
    }
  },
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  etherscan: {
    apiKey: etherscanApiKey,
  },
};
