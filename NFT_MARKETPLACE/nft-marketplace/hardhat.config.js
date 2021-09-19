require("@nomiclabs/hardhat-waffle");

const fs = require('fs')
const privateKey = fs.readFileSync('.secret').toString()
const projectId = 'dea63c975eed462cb0a4ba46bbd6479e'

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337 // according to hardhat docs
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`
    },
    mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${projectId}`
    }
  },
  solidity: "0.8.4",
};
