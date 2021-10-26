const hre = require("hardhat");

async function main() {

    // 컨트렉트 업그레이드시 사용
    const proxyAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
    const SmipleStoregeUpgrade2 = await hre.ethers.getContractFactory("SimpleStoregeUpgrade2");
    const ssu2 = await upgrades.upgradeProxy(proxyAddress, SmipleStoregeUpgrade2);

    console.log("SimpleStoregeUpgrade deployed to:", ssu2.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
