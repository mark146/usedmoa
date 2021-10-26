// 참고
// https://github.com/rickhysis/erc1155-demo
// https://dapp-world.com/smartbook/create-erc1155-with-openzeppelin-aUyt
// https://forum.moralis.io/t/erc-1155-get-token-uri/2858/14
// https://www.youtube.com/watch?v=M37KxPoa7HU
// https://www.youtube.com/watch?v=J4p1sdo3Rz4
// https://rickhysiswanto.medium.com/building-erc1155-smart-contract-with-openzeppelin-3-c7ed05518566
// https://stackoverflow.com/questions/68661290/erc1155-token-how-to-create-erc1155-token
// https://www.youtube.com/watch?v=M37KxPoa7HU
// https://docs.ethers.io/v5/api/signer/#VoidSigner
const { ethers } = require("hardhat");


describe("UsedMoaTokenV3", function () {

    // 내부 네트워크 계정 조회
    const wallets = waffle.provider.getWallets();

    // 계약 생성
    before(async () => {
        const ERC_1155_v1 = await ethers.getContractFactory("UsedMoaTokenV3");
        const erc_1155 = await ERC_1155_v1.deploy("UsedMoaTokenV3", "UMT");
        await erc_1155.deployed();

        this.instance = erc_1155;
    });


    // 토큰 생성
    it("ERC Token Create", async () => {
        await this.instance.mintTokens(wallets[0].address, 0, 20000);
        await this.instance.mintTokens(wallets[1].address, 0, 100);
        // console.log("wallets[0].address: ",wallets[0].address);
        // console.log("wallets[1].address: ",wallets[1].address);
        // console.log("wallets[2].address: ",wallets[2].address);
    });


    // 보유 토큰 정보 조회
    it("token info check", async () => {
        console.log("wallets[0] - getBalance: ",BigInt(await this.instance.getBalance(wallets[0].address, 0)));
        console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address, 0)));
    });


    // 토큰 전송
    it("token send", async () => {
        const sendToken = await this.instance.connect(wallets[0]).sendToken(wallets[0].address, wallets[1].address, 0, 10000);
        //console.log("sendToken: ",sendToken);
        console.log("maxPriorityFeePerGas: ",BigInt(sendToken.maxPriorityFeePerGas));
        console.log("maxFeePerGas: ",BigInt(sendToken.maxFeePerGas));
        console.log("gasLimit: ",BigInt(sendToken.gasLimit));
    });


    // 보유 토큰 정보 조회
    it("token info check", async () => {
        console.log("wallets[0] - getBalance: ",BigInt(await this.instance.getBalance(wallets[0].address, 0)));
        console.log("wallets[1] - getBalance: ",BigInt(await this.instance.getBalance(wallets[1].address, 0)));
    });


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