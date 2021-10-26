/*
const { expect } = require("chai");


ethers변수는 전역 범위에서 사용할 수 있습니다. 
코드가 항상 명시적이면 상단에 다음 줄을 추가할 수 있습니다.

const { ethers } = require("hardhat");


describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {


    Signerethers.js의 A 는 이더리움 계정을 나타내는 객체입니다. 
    계약 및 기타 계정으로 거래를 보내는 데 사용됩니다. 
    여기에서 우리는 연결된 노드의 계정 목록을 얻었습니다. 
    이 경우에는 Hardhat Network 이며 첫 번째 계정 만 유지합니다.

    const [owner] = await ethers.getSigners();
    console.log("owner:", owner);

    ContractFactoryethers.js의 A 는 새로운 스마트 계약을 배포하는 데 사용되는 추상화이므로 
    Token여기에 토큰 계약 인스턴스용 팩토리가 있습니다.

    const Token = await ethers.getContractFactory("Token");


    호출 deploy()A의 것은 ContractFactory배포를 시작하고 반환 PromiseA와 그 해결합니다 
    Contract. 이것은 각 스마트 계약 기능에 대한 메서드가 있는 개체입니다.

    const hardhatToken = await Token.deploy();


    계약이 배포되면 계약 메서드를 호출하고 hardhatToken이를 사용하여 를 호출하여 소유자 계정의 잔액을 얻을 수 balanceOf()있습니다.

    전체 공급을 받는 토큰의 소유자는 배포를 만드는 계정이며 hardhat-ethers플러그인을 사용할 때 기본적으로 
    첫 번째 서명자 ContractFactory와 Contract인스턴스가 연결된다는 점을 기억하십시오. 
    이는 owner변수 의 계정 이 배포를 실행 balanceOf()했으며 전체 공급량을 반환해야 함을 의미합니다 .

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
*/