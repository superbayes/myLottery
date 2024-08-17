# lottery Hardhat Project

这是一个基于solidity的彩票智能合约.

我们设置了一个清晰而又简单的游戏规则,让你有10%的概率获取到超过4倍的收益(20%的获奖者分享每一期总奖金池80%的奖金)

* 每一期彩票售卖期为7天
* 每一张彩票价格0.1eth
* 每一期总人数不低于100, 如果不满足,则资金原路退回给用户



how to use hardhat

``````shell
npm init -y 
npm i -D hardhat 
npx hardhat init
npm install dotenv --save
npm install --save-dev @openzeppelin/contracts @openzeppelin/contracts-upgradeable @openzeppelin/hardhat-upgrades 

``````



This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
