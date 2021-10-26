const { ethers } = require("hardhat");


describe("UsedMoaToken", function () {

    // 내부 네트워크 계정 조회
    const wallets = waffle.provider.getWallets();

    // 계약 생성
    before(async () => {
        const ERC_20 = await ethers.getContractFactory("UsedMoaToken");
        const erc_20 = await ERC_20.deploy();
        await erc_20.deployed();

        this.instance = erc_20;
    });


    // 토큰 생성
    it("ERC Token Create", async () => {
        //await this.instance.tokenMint(wallets[0].address, 20000);
        await this.instance.tokenMint(wallets[1].address, 100);
        // console.log("wallets[0].address: ",wallets[0].address);
        // console.log("wallets[1].address: ",wallets[1].address);
        // console.log("wallets[2].address: ",wallets[2].address);
    });


    // 보유 토큰 정보 조회
    it("token info check", async () => {
        console.log("wallets[0] - getBalance: ",BigInt(await this.instance.getBalance(wallets[0].address)));
        console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address)));
    });


    // 토큰 전송
    it("token send", async () => {
        const sendToken = await this.instance.connect(wallets[0]).sendTokens(wallets[1].address, 10000);
        // console.log("sendToken: ",sendToken);
        console.log("maxPriorityFeePerGas: ",BigInt(sendToken.maxPriorityFeePerGas));
        console.log("maxFeePerGas: ",BigInt(sendToken.maxFeePerGas));
        console.log("gasLimit: ",BigInt(sendToken.gasLimit));
    });


    // 보유 토큰 정보 조회
    it("token info check", async () => {
        console.log("wallets[0] - getBalance: ",BigInt(await this.instance.getBalance(wallets[0].address)));
        console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address)));
    });


    // 보유 토큰 정보 조회
    it("create auction ", async () => {
        // console.log("wallets[0] - getBalance: ",BigInt(await this.instance.getBalance(wallets[0].address)));
        // console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address)));
    });
});