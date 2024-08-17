const { ethers, upgrades } = require("hardhat");
const fs = require('fs');

async function main() {
    //通过合约工厂创建合约对象
    const MyLottery = await ethers.getContractFactory("MyLottery");
    //通过代理的方式部署合约
    const ownerAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";
    const platform = await upgrades.deployProxy(MyLottery, [ownerAddress], { initializer: "initialize" });
    //等待合约执行
    await platform.waitForDeployment();
    //输出合约的地址
    console.log("MyLottery deployed to:", platform.target);
    // Save the contract address to a file
    fs.writeFileSync('./deployedAddress.txt', platform.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });