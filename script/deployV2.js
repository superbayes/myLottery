const { ethers, upgrades } = require("hardhat");
const fs = require('fs');

async function main() {
    const MyLotteryV2 = await ethers.getContractFactory("MyLottery");

    // 代理合约地址,在第一次部署成功后就有了,可以保存下来
    const proxyAddress = fs.readFileSync('./deployedAddress.txt', 'utf8');
    const platform = await upgrades.upgradeProxy(proxyAddress, MyLotteryV2);

    console.log("CrowdfundingPlatform upgraded");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });