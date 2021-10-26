const hre = require("hardhat");

async function main() {

    /*
    getSigners()는 이더리움 계정을 나타내는 객체입니다.
    계약 및 기타 계정으로 거래를 보내는 데 사용됩니다.
    여기에서 우리는 연결된 노드의 계정 목록을 얻었습니다.
    이 경우에는 Hardhat Network 이며 첫 번째 계정 만 유지합니다.
    */
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the deployer:", deployer.address);
    console.log("deployer balance:", (await deployer.getBalance()).toString());

    //const Token = await hre.ethers.getContractFactory("Token");
    const Token = await hre.ethers.getContractFactory("UsedMoaTokenV3");
    const token = await Token.deploy("UsedMoaToken", "UMT");

    console.log("Token address:", token.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });