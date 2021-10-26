const hre = require("hardhat");
const {expect} = require("chai");

describe ("SimpleStoregeUpgrade", function () {

    const wallets = waffle.provider.getWallets();// 내부 네트워크 계정 가져옴

    before(async () => {
        const signer = waffle.provider.getSigner(2);
        const SimpleStorageUpgrade = await hre.artifacts.readArtifact("SimpleStoregeUpgrade");

        // 단위테스트 과정에서 컨트랙트 배포하고 실행함
        this.instance = await waffle.deployContract(signer, SimpleStorageUpgrade);
    });

    it("should change the value", async () => {
        const tx = await this.instance.connect(wallets[1]).set(500);
        const v = await this.instance.get();
        expect(v).to.be.equal(500);
    });

    it("should revert", async () => {
        await expect(this.instance.set(4000)).to.be.revertedWith("should be less than 5000");
    } );

})