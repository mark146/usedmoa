const hre = require("hardhat");


// 2. 실행할 코드 작성
async function main() {

    // 컨트렉트 이름 참고해서 스마트 계약서 가져옴
    const SmipleStoregeUpgrade = await hre.ethers.getContractFactory("SimpleStoregeUpgrade");

    // [500] : SimpleStoregeUpgrade 초기값, initializer : 초기화 함수 이름 지정
    const ssu = await upgrades.deployProxy(SmipleStoregeUpgrade, [500], {initializer: 'set'});

    // 주소 출력
    console.log("SimpleStoregeUpgrade deployed to:", ssu.address);
}


// 1. 실행
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
