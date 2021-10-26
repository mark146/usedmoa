/*
const { expect } = require("chai");

// 'describe'는 테스트를 구성할 수 있는 모카 함수입니다. 이건.
// 실제로 필요하지 않지만 테스트를 정리하면 디버깅이 가능합니다.
// 더 쉽습니다. 모든 Mocha 기능은 글로벌 범위에서 사용할 수 있습니다.

// 테스트 제품군의 섹션 이름과 콜백을 수신합니다.
// 콜백은 해당 섹션의 테스트를 정의해야 합니다. 이 콜백은 할 수 없습니다.
// 비동기 함수.
describe("Token contract", function () {
  // Mocha에는 테스트 러너의 후크에 연결할 수 있는 네 가지 기능이 있습니다.
  // 라이프사이클 These are: `before`, `beforeEach`, `after`, `afterEach`.

  // 테스트 환경을 설정하고 청소하는 데 매우 유용합니다.
  // 실행 후 위로 이동합니다.

  // 공통 패턴은 일부 변수를 선언하고 변수에 할당하는 것입니다.
  // `before` and `beforeEach` callbacks.

  let Token;
  let hardhatToken;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  // `beforeEach` 각 테스트 전에 실행되며, 다음 시간마다 계약을 다시 체결합니다.
  // 시간. 비동기일 수 있는 콜백을 수신합니다.
  beforeEach(async function () {
    // 계약 공장 및 서명자를 여기로 보내십시오.
    Token = await ethers.getContractFactory("Token");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // 계약을 배포하려면 Token.deploy()를 호출하고 기다리면 됩니다.
    // 해당 트랜잭션이 한 번 실행되면 배포됩니다.
    // 채굴.
    hardhatToken = await Token.deploy();
  });

  // 하위 섹션을 만들기 위한 호출을 중첩할 수 있습니다.
  describe("Deployment", function () {
    // 'it'는 또 다른 Mocha 함수입니다. 이것은 당신이 정의하기 위해 사용하는 것입니다.
    // 테스트. 테스트 이름과 콜백 함수를 수신합니다.

    // 콜백 기능이 비동기일 경우 모카는 "기다릴" 것입니다.
    it("Should set the right owner", async function () {
      // 값을 수신하고 이를 Assertion 개체로 래핑합니다. 이것들
      // 객체는 값을 주장하는 유틸리티 메서드가 많습니다.

      // 이 테스트에서는 계약에 저장된 소유자 변수가 동일할 것으로 예상합니다.
      // 서명인의 주인에게.
      expect(await hardhatToken.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      // 소유자로부터 addr1로 토큰 50개 전송
      await hardhatToken.transfer(addr1.address, 50);
      const addr1Balance = await hardhatToken.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);

      // 토큰 50개를 addr1에서 addr2로 전송
      // 다른 계정에서 트랜잭션을 보낼 때 .connect(서명자)를 사용합니다.
      await hardhatToken.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await hardhatToken.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
      const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

      // addr1(0 토큰)에서 소유자(10000 토큰)로 토큰 1개를 보내 보십시오.
      // `require` 평가하여 트랜잭션을 되돌립니다.
      await expect(
        hardhatToken.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("Not enough tokens");

      // 소유자 잔액이 변경되지 않았어야 합니다.
      expect(await hardhatToken.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });

    it("Should update balances after transfers", async function () {
      const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

      // 소유자에서 addr1로 토큰 100개를 전송합니다.
      await hardhatToken.transfer(addr1.address, 100);

      // 소유자로부터 다른 50개의 토큰을 addr2로 전송합니다.
      await hardhatToken.transfer(addr2.address, 50);

      // 잔액을 확인하다.
      const finalOwnerBalance = await hardhatToken.balanceOf(owner.address);
      expect(finalOwnerBalance).to.equal(initialOwnerBalance - 150);

      const addr1Balance = await hardhatToken.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(100);

      const addr2Balance = await hardhatToken.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });
  });
});

 */