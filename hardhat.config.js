require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("dotenv").config();

//require("@nomiclabs/hardhat-ganache");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.AICHEMY_ID,
        //blockNumber: 20291600 // 可选
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545"
   },
    sepolia: {
      url: "https://sepolia.infura.io/v3/" + process.env.INFURA_ID, // Sepolia网络的RPC URL
      chainId: 11155111, // Sepolia网络的Chain ID
      accounts: [process.env.PRIVATE_KEY] // 私钥
    },
    bsctestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/", // BSC测试网的RPC URL
      chainId: 97, // BSC测试网的Chain ID
      accounts: [process.env.PRIVATE_KEY] // 私钥
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56, // BSC主网的链ID
      accounts: [process.env.PRIVATE_KEY] //账户私钥（注意保密）
    }
  }
};