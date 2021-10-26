const { ethers } = require("hardhat");
const { expect } = require('chai');

describe("SimpleAuction", function () {

    // 내부 네트워크 계정 조회
    const wallets = waffle.provider.getWallets();

    // 경매 계약 생성
    before(async () => {
        this.SimpleAuction = await ethers.getContractFactory("SimpleAuction");
    });

    // 경매 시간 및 수혜자 설정
    // _biddingTime : 현재로 부터 얼마동안 경매를 진행할 것인지 설정하며
    // _beneficiary : 이 경매가 끝났을 때 수혜자를 설정하게 됩니다.
    beforeEach(async () => {
        this.auction = await this.SimpleAuction.deploy(30, wallets[0].address);
        await this.auction.deployed();
        console.log("wallets: ",wallets[0].address);
    });


    // before(async () => {
    //     const Auction = await ethers.getContractFactory("SimpleAuction");
    //
    //     // 경매 시간 및 수혜자 설정
    //     // _biddingTime : 현재로 부터 얼마동안 경매를 진행할 것인지 설정하며
    //     // _beneficiary : 이 경매가 끝났을 때 수혜자를 설정하게 됩니다.
    //     const auction = await Auction.deploy(30, wallets[0].address);
    //     // await auction.deployed();
    //     this.instance = auction;
    // });


    // Test case
    // 2) bid() - 기능 : ETH를 이용해 경매에 참여합니다.
    // https://github.com/MolochVentures/moloch/tree/4e786db8a4aa3158287e0935dcbc7b1e43416e38/test#moloch-testing-guide
    it("Join auction", async () => {

        // expect(await this.instance.connect(wallets[1]).bid()).to.equal(100);
        // expect(await this.instance.connect(wallets[1]).bid()).to.equal(200);
        // await this.instance.connect(wallets[1]).bid();
        // await this.instance.connect(wallets[2]).bid();
        // await this.instance.mintTokens(wallets[1].address, 0, 100);
        // console.log("wallets[0].address: ",wallets[0].address);
        // console.log("wallets[1].address: ",wallets[1].address);
        // console.log("wallets[2].address: ",wallets[2].address);
    });


    // 보유 토큰 정보 조회
    // it("token info check", async () => {
    //     console.log("wallets[0] - getBalance: ",BigInt(await this.instance.getBalance(wallets[0].address, 0)));
    //     console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address, 0)));
    // });
    //
    //
    // // 토큰 전송
    // it("token send", async () => {
    //     const sendToken = await this.instance.connect(wallets[0]).sendToken(wallets[0].address, wallets[1].address, 0, 10000);
    //     //console.log("sendToken: ",sendToken);
    //     console.log("maxPriorityFeePerGas: ",BigInt(sendToken.maxPriorityFeePerGas));
    //     console.log("maxFeePerGas: ",BigInt(sendToken.maxFeePerGas));
    //     console.log("gasLimit: ",BigInt(sendToken.gasLimit));
    // });
    //
    //
    // // 보유 토큰 정보 조회
    // it("token info check", async () => {
    //     console.log("wallets[0] - getBalance: ",BigInt(await this.instance.getBalance(wallets[0].address, 0)));
    //     console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address, 0)));
    // });


    // NFT 생성
    // it("nft token create", async () => {
    //     const createNFT = await this.instance.mintTokens(wallets[1].address, 3, 1);
    //     console.log("createNFT: ",createNFT);
    // });
    //
    // // NFT 조회
    // it("nft token info check", async () => {
    //     const nftCheck = await this.instance.uri(3);
    //     console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address, 3)));
    //     console.log("nftCheck: ",nftCheck);
    // });
});