const dotenv = require('dotenv').config();
const {auctionModel} = require('../models')
const AuctionListInfo = require('../dto/auctionListInfo');
const AuctionInfo = require('../dto/auctionInfo');
const axios = require("axios");
const fs = require("fs");
const formData = require("form-data");
const path = require('path');
const Web3 = require('web3');
const Tx = require('ethereumjs-tx').Transaction;
const moment = require('moment').tz.setDefault("Asia/Seoul"); // TODO 시간 처리 부분 다시 공부 -> dayjs
const web3js = new Web3(
    new Web3.providers.HttpProvider('https://ropsten.infura.io/v3/' + process.env.INFURA_KEY)
);


// const erc20_abi = JSON.parse(fs.readFileSync('/usr/local/nodejs/abi/erc20_abi.json', 'utf-8'));
// const contract = new web3js.eth.Contract(erc20_abi, process.env.ERC20_CONTRACT_ADDRESS);
const erc1155Abi = JSON.parse(fs.readFileSync('/usr/local/nodejs/abi/erc1155_abi.json', 'utf-8'));
const contract = new web3js.eth.Contract(erc1155Abi, process.env.ERC1155_CONTRACT_ADDRESS);


// 경매 생성 - (시나리오) 1. 이미지 ipfs 저장 후 경로 호출 -> 2. json 파일 생성 -> 3. nft 생성
const auctionCreate = async (userInfo) => {
    //console.log("auctionService - auctionCreate - userInfo: ",userInfo)

    // 1. 이미지 ipfs 저장 후 경로 호출
    const jsonResult = await pinFileToIPFS(`images/1633608722381_.png`);
    console.log("jsonResult: ","https://ipfs.io/ipfs/"+jsonResult);
    // 결과 값: jsonResult:  https://ipfs.io/ipfs/QmdZ5m7cKRw36Ev2uwTghLMhvcJ1bWAVtC9TbSNjnhnWxh


    // 경매 시작, 종료 시간 추출 -> dayjs 변경 예정
    const startTime = moment(userInfo.get("auction_start_time"));
    const endTime = moment(userInfo.get("auction_end_time"));
    console.log("startTime: ",startTime);
    console.log("endTime: ", endTime);

    // 경매 진행 시간 계산
    const auctionPlayTime = endTime.diff(startTime, "seconds")
    console.log("auctionPlayTime: ", auctionPlayTime);

    // 사용자 보유 토큰 갯수 조회
    const tokenInfo = await getUserTokenInfo(process.env.TOKEN_MASTER_ADDRESS);
    console.log("tokenInfo: ",tokenInfo);

    // 경매 인덱스 정보 조회.
    // TODO - 경매 없을 경우 예외처리
    const auctionId = parseInt(await auctionIdCheck());
    console.log("auctionId: ",auctionId);

    console.log(`auctionPlayTime: ${auctionPlayTime}, TOKEN_MASTER_ADDRESS : ${process.env.TOKEN_MASTER_ADDRESS}, product_price: ${parseInt(userInfo.get("product_price"))} `);
    
    // 경매 등록 (경매 진행 시간, 판매자 주소, 초기금액)
    await auctionRegister(auctionPlayTime, process.env.TOKEN_MASTER_ADDRESS, parseInt(userInfo.get("product_price")));

    // 경매 정보 조회
    var auctionInfo = getAuctionInfo(auctionId);
    if(auctionInfo === undefined) {
        console.log("auctionInfo: undefined");
    } else {
        console.log("auctionInfo: ",auctionInfo);
        console.log("auctionStatus: ",auctionInfo.auctionStatus);
        console.log("highestBidder: ",auctionInfo.highestBidder);
        console.log("highestBiddingPrice: ",auctionInfo.highestBiddingPrice);
        const dateString = moment.unix(auctionInfo.auctionEndTime).utc();
        console.log("auctionEndTime: ",dateString);
    }


    // 경매 메타데이터 정보 조회.
    const auctionUriInfo = getAuctionUri(auctionId);
    console.log("auctionUriInfo: ",auctionUriInfo);


    // 3. 메타데이터 정보가 담긴 json 파일 생성
    /**
     // 메타데이터 구조
     "auctionId" : 0, // 경매 고유 ID
     "produectName" : "Asset Name", // 제품명
     "imageUri" : "ipfs://YOUR_ASSET_CID", // (이미지) NFT의 디지털 자산에 대한 링크인 문자열
     "description": "description...", // NFT의 설명을 저장하는 문자열
     "attributes": {
            "creator": "creator name", // 판매자
            "startTime": 2021-10-12 23:00:00, // 등록일자
            "endTime": 2021-10-12 23:00:00, // 경매 종료 시간
            "highestBidder": "test1", // 최고 입찰자
            "highestBiddingPrice": "5", // 최고 입찰가
         }
     */
    const attributesJson = `{ "creator" : ${auctionUriInfo.creator}, "highestBidder" : ${auctionUriInfo.highestBidder}, "highestBiddingPrice" : ${userInfo.get("product_price")
    }, "startTime" : ${userInfo.get("auction_start_time")}, "endTime" : ${userInfo.get("auction_end_time")} }`;

    let metaDataInfo = new Map();
    metaDataInfo.set("auctionId", auctionId);
    metaDataInfo.set("imageUri", "https://ipfs.io/ipfs/"+jsonResult);
    metaDataInfo.set("produectName", userInfo.get("product_name"));
    metaDataInfo.set("init_product_price", userInfo.get("product_price"));
    metaDataInfo.set("description", userInfo.get("content"));
    metaDataInfo.set("attributes", attributesJson);
    // console.log("metaDataInfo: ",metaDataInfo);

    // map -> Json 변환 - 참고 : https://velog.io/@kwonh/ES6-%EB%8D%B0%EC%9D%B4%ED%84%B0%EC%BB%AC%EB%A0%89%EC%85%984-Map%EC%9C%BC%EB%A1%9C-%EA%B0%9D%EC%B2%B4-%EB%8C%80%EC%8B%A0%ED%95%98%EA%B8%B0
    const modified = [...metaDataInfo]
    const reducerApplied = modified.reduce((accum,current)=>{
        return {
            ...accum,
            [current[0]]:current[1]
        }
    },{})
    console.log("reducerApplied: ", reducerApplied);
    let json = JSON.stringify(reducerApplied);


    // 비동기방식으로 json 파일 저장 (writeFile, createWriteStream, writeFileSync)
    fs.writeFile(`./json/${auctionId}.json`, json, 'utf8', (err) => {
        if (err) throw err;
        console.log('The file has been saved!');
    });

    let jsonFile = fs.readFileSync(`./json/${auctionId}.json`,'utf-8');
    console.log('jsonFile: ',jsonFile);


    // IPFS 서버에 json 파일 생성
    // const jsonResult = await pinJSONToIPFS(reducerApplied);
    // console.log("jsonResult: ","https://ipfs.io/ipfs/"+jsonResult);
    //
    //
    // // json 파일 정보 조회
    // const pinResult = await pinCheck(jsonResult);
    // console.log("pinResult: ",pinResult);
    //
    // // string -> json 변환 - 참고 : https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse
    // const parsedData = JSON.parse(`\'${pinResult.attributes}\'`);
    // console.log("parsedData: ",parsedData);
}


// 경매 목록 조회 - 참고 : https://fenderist.tistory.com/313
const auctionList = async () => {
    console.info("auctionList 실행");

    // 블록체인에 등록된 경매 정보들 조회 
    const list = await getAuctionPlayList();
    console.log("getAuctionPlayList: ",list);
    console.log("list[1]: ",list[1].index);
    
    // 데이터 가공 (id값, 경매 상태값, 제목 or 제품명, 초기 가격, 경매인 정보)
    var auctionInfoList = new Array();
    for (var i = 1; i < list.length; ++i) {

        // URI 값 추출
        const uri = await getAuctionUri(list[i].index);
        const words = uri.split('/');
        const filePath = "/usr/local/nodejs/"+words[3]+"/"+words[4];
        console.log("filePath: ",filePath);

        // json 파일 -> json 객체 변환
        const jsonFile = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
        console.log("jsonFile: ",jsonFile);

        const auctionInfo = await getAuctionInfo(list[i].index);
        console.info("auctionInfo: ",auctionInfo);

        // 클라이언트 전달용 객체 생성
        var auction;
        if(jsonFile.image === undefined) {
            auction = new AuctionListInfo(list[i].index, auctionInfo.creator, jsonFile.imageUri, list[i].auctionStatus,
                list[i].highestBidder, list[i].highestBiddingPrice, list[i].auctionEndTime);
        } else {
            auction = new AuctionListInfo(list[i].index, auctionInfo.creator, jsonFile.imageUri, list[i].auctionStatus,
                list[i].highestBidder, list[i].highestBiddingPrice, list[i].auctionEndTime);
        }

        auctionInfoList.push(auction);
    }
    //console.info("auctionInfoList: ",auctionInfoList); // 목록들

    return auctionInfoList;
}


// 경매 정보 조회
const auctionDetail = async (auctionId) => {
    console.info("auctionDetail 실행 - auctionId: ",auctionId );

    const auctionInfo = await getAuctionInfo(auctionId);
    console.info("auctionInfo: ",auctionInfo);
    
    // 블록체인에 등록된 경매 메타데이터 정보 조회
    const uri = await getAuctionUri(auctionId);
    const words = uri.split('/');
    const filePath = "/usr/local/nodejs/"+words[3]+"/"+words[4];
    //
    // // json 파일 -> json 객체 변환
    const jsonFile = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    console.info("jsonFile: ",jsonFile);




    // 상품명, 설명, 상품 이미지 정보, 경매 진행상황, 최고 입찰자, 최고 입찰가, 종료 시간
    const auction = new AuctionInfo(auctionInfo.creator, jsonFile.produectName, jsonFile.description, jsonFile.imageUri, auctionInfo.auctionStatus,
        auctionInfo.highestBidder, auctionInfo.highestBiddingPrice, auctionInfo.auctionEndTime);

    return auction;
}


// 경매 입찰
const auctionBid = async (auctionId, userAdress, bidPrice) => {
    console.info("auctionBid 실행");
    // await this.instance.connect(wallets[1]).bid(this.auctionId_v2, 20);

    // 
    const master_tokenInfo = await getUserTokenInfo(process.env.TOKEN_MASTER_ADDRESS);
    console.log("master_tokenInfo: ",master_tokenInfo);

    // 사용자 보유 토큰 갯수 조회
    const tokenInfo = await getUserTokenInfo(userAdress);
    console.log("userAdress_tokenInfo: ",tokenInfo);

    // 토큰 발급
    // userTokenMint();

    // 입찰 진행
    console.log(`auctionId: ${auctionId}, userAdress: ${userAdress}, bidPrice: ${bidPrice}`)
    // sendAuctionBid(auctionId, userAdress, bidPrice)
    //     .then(function (response) {
    //         console.log("response: ",response);
    //     })
    //     .catch(function (error) {
    //         console.log("error: ",error)
    //     });

    await sendAuctionBid(auctionId, userAdress, bidPrice);
    return await auctionDetail(auctionId);
}


// 경매 종료
const auctionEnd = async (auctionId) => {
    console.info("auctionEnd 실행 - auctionId: ",auctionId);

    sendAuctionEnd(auctionId)
        .then(function (response) {
            console.log("response: ",response);
        })
        .catch(function (error) {
            console.log("error: ",error)
        });
    // await contract.methods.auctionEnd(auction_id).call();
}


/* ############################################## */

// 테스트용 토큰 발급
const userTokenMint = async () => {

    // erc 1155 방식 v1
    const from = web3js.utils.toChecksumAddress(process.env.TOKEN_MASTER_ADDRESS);
    const to = web3js.utils.toChecksumAddress(process.env.USER_V2_ADDRESS);
    const erc1155TokenAddress = web3js.utils.toChecksumAddress(process.env.ERC1155_CONTRACT_ADDRESS);

    // ether 단위 정보 - 참고 : https://web3js.readthedocs.io/en/v1.5.2/web3-utils.html?highlight=toHex#tohex
    const amount = web3js.utils.toWei('50000', 'wei');

    const chainId = await web3js.eth.getChainId();

    // 개인 키로 거래에 서명
    const signedTx  = await web3js.eth.accounts.signTransaction({
        "to": erc1155TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
        "gas": 5000000,
        "chainId": chainId,
        "value":"0x0",
        "data": contract.methods.sendToken(from, to, 0, amount).encodeABI()
    },  process.env.TOKEN_MASTER_PK)
    console.log("signedTx : ",signedTx.rawTransaction);

    // 트랜잭션 전송
    web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
        .once("transactionHash", hash => {
            // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
            console.info("transactionHash: ", "https://ropsten.etherscan.io/tx/" + hash)
        })
        .once("receipt", receipt => {
            console.log("토큰 발급");
        })
        .on("error: ", console.error)
}

// IPFS 서버에 이미지 파일 업로드 - 참고 : https://docs.pinata.cloud/api-pinning/pin-file
const pinFileToIPFS = async (path) => {
    const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`;
    console.log(`pinFileToIPFS - ./${path}`)

    let data = new formData();
    data.append('file', fs.createReadStream(`./${path}`));

    const metadata = JSON.stringify({
        name: 'testname2', // 파일 이름
        keyvalues: {
            exampleKey: 'exampleValue'
        }
    });
    data.append('pinataMetadata', metadata);

    // Pinata는 파일을 추가할 수 있도록 추가 옵션을 지원합니다. 현재 이 끝점에 다음 옵션이 지원됩니다.
    const pinataOptions = JSON.stringify({
        cidVersion: 0, // 콘텐츠에 대한 해시 생성은 IPFS가 CID 버전입니다. 옵션은 "0"(CIDv0) 또는 "1"(CIDv1)입니다.
        customPinPolicy: {
            regions: [
                {
                    id: 'FRA1',
                    desiredReplicationCount: 1
                },
                {
                    id: 'NYC1',
                    desiredReplicationCount: 2
                }
            ]
        }
    });
    data.append('pinataOptions', pinataOptions);

    return axios
        .post(url, data, {
            maxBodyLength: 'Infinity', //this is needed to prevent axios from erroring out with large files
            headers: {
                'Content-Type': `multipart/form-data; boundary=${data._boundary}`,
                pinata_api_key: process.env.PINATA_API_KEY,
                pinata_secret_api_key: process.env.PINATA_SECRET_API_KEY
            }
        })
        .then(function (response) {
            console.log("response.data: ",response.data);
            return response.data.IpfsHash;
        })
        .catch(function (error) {
            console.log("error: ",error)
        });
};

// IPFS 서버에 json 파일 생성
const pinJSONToIPFS = async (JSONBody) => {
    const url = `https://api.pinata.cloud/pinning/pinJSONToIPFS`;

    return axios
        .post(url, JSONBody, {
            headers: {
                pinata_api_key: process.env.PINATA_API_KEY,
                pinata_secret_api_key: process.env.PINATA_SECRET_API_KEY
            }
        })
        .then(function (response) {
            //console.log(`pinJSONToIPFS - response.data: `, response)
            // console.log(`pinJSONToIPFS - response: `, response.data.IpfsHash)
            return response.data.IpfsHash;
        })
        .catch(function (error) {
            console.log(`error: `,error)
        });
};

// IPFS 서버에 있는 json 파일 정보 조회
const pinCheck = async (info) => {
    try {
        const instance = axios.create({
            baseURL: 'https://gateway.pinata.cloud'
        })
        return await instance.get(`/ipfs/${info}`, { timeout: 5000 })
            .then((res) => {
                // console.log("pinCheck - res: ", res.data);
                return res.data;
            })
    } catch (err) {
        console.log("tokenCheckError: ", err);
    }
}

// 마지막에 등록된 경매 인덱스 정보 조회
const auctionIdCheck = async () => {
    return await contract.methods.auctionIdCheck().call();
}

// 사용자 보유 토큰 정보 조회
const getUserTokenInfo = async (user_address) => {
    return await contract.methods.getBalance(user_address, 0).call();
}

// 경매 정보 조회
const getAuctionInfo = async (auction_id) => {
    return await contract.methods.auctionCheck(auction_id).call();
}

// 경매 목록 조회
const getAuctionPlayList = async () => {
    return await contract.methods.auctionPlayList().call();
}

// 경매 메타데이터 정보 조회
const getAuctionUri = async (auction_id) => {
    return await contract.methods.uri(auction_id).call();
}

// 블록체인에 경매 정보 등록
const auctionRegister = async (play_time, user_address, product_price) => {

    // 유저 지갑 정보 싸인 처리
    const from = web3js.utils.toChecksumAddress(user_address);
    const erc1155TokenAddress = web3js.utils.toChecksumAddress(process.env.ERC1155_CONTRACT_ADDRESS);
    const chainId = await web3js.eth.getChainId();

    // ether 단위 정보 - 참고 : https://web3js.readthedocs.io/en/v1.5.2/web3-utils.html?highlight=toHex#tohex
    const amount = web3js.utils.toWei(`${product_price}`, 'wei');


    // 개인 키로 거래에 서명
    const signedTx  = await web3js.eth.accounts.signTransaction({
        "to": erc1155TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
        "gas": 5000000,
        "chainId": chainId,
        "value":"0x0",
        "data": contract.methods.auctionRegister(play_time, from, amount).encodeABI()
    }, process.env.TOKEN_MASTER_PK) // TODO - 전송 방식 고민
    // console.log("signedTx : ",signedTx.rawTransaction);

    // 트랜잭션 전송
    await web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
        .once("transactionHash", hash => {
            // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
            console.info("transactionHash: https://ropsten.etherscan.io/tx/" + hash)

            return ("https://ropsten.etherscan.io/tx/" + hash);
        })
        .once("receipt", receipt => {
            console.log("거래 후 토큰 정보: ",receipt);
        })
        .on("error: ", console.error)
}


// 블록체인에 경매 입찰 등록
const sendAuctionBid = async (auctionId, userAdress, price) => {

    // 유저 지갑 정보 싸인 처리
    const from = web3js.utils.toChecksumAddress(userAdress);
    const erc1155TokenAddress = web3js.utils.toChecksumAddress(process.env.ERC1155_CONTRACT_ADDRESS);
    const chainId = await web3js.eth.getChainId();

    // ether 단위 정보 - 참고 : https://web3js.readthedocs.io/en/v1.5.2/web3-utils.html?highlight=toHex#tohex
    const amount = web3js.utils.toWei(`${price}`, 'wei');


    // 개인 키로 거래에 서명
    const signedTx  = await web3js.eth.accounts.signTransaction({
        "to": erc1155TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
        "gas": 5000000,
        "chainId": chainId,
        "value":"0x0",
        "data": contract.methods.auctionBid(auctionId, from, amount).encodeABI()
    }, process.env.TOKEN_MASTER_PK) // TODO - 전송 방식 고민
    // console.log("signedTx : ",signedTx.rawTransaction);

    // 트랜잭션 전송
    await web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
        .once("transactionHash", hash => {
            // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
            console.info("transactionHash: https://ropsten.etherscan.io/tx/" + hash)

            return ("https://ropsten.etherscan.io/tx/" + hash);
        })
        .once("receipt", receipt => {
            //console.log("거래 후 토큰 정보: ",receipt);
        })
        .on("error: ", console.error)
}


// 블록체인에 경매 종료
const sendAuctionEnd = async (auctionId) => {

    // 유저 지갑 정보 싸인 처리
    const erc1155TokenAddress = web3js.utils.toChecksumAddress(process.env.ERC1155_CONTRACT_ADDRESS);
    const chainId = await web3js.eth.getChainId();


    // 개인 키로 거래에 서명
    const signedTx  = await web3js.eth.accounts.signTransaction({
        "to": erc1155TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
        "gas": 5000000,
        "chainId": chainId,
        "value":"0x0",
        "data": contract.methods.auctionEnd(auctionId).encodeABI()
    }, process.env.TOKEN_MASTER_PK) // TODO - 전송 방식 고민
    // console.log("signedTx : ",signedTx.rawTransaction);

    // 트랜잭션 전송
    await web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
        .once("transactionHash", hash => {
            // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
            console.info("transactionHash: https://ropsten.etherscan.io/tx/" + hash)

            return ("https://ropsten.etherscan.io/tx/" + hash);
        })
        .once("receipt", receipt => {
            //console.log("거래 후 토큰 정보: ",receipt);
        })
        .on("error: ", console.error)
}


// Web3.js는 내부적으로 HTTP 나 IPC를 통해 JSON RPC API를 호출 하도록 되어있다
/*
const erc1155Send = async () => {
    console.log("거래 전 토큰 정보");

    // erc 1155 방식 v1
    const from = web3js.utils.toChecksumAddress(token_master);
    const to = web3js.utils.toChecksumAddress(address);
    const erc1155TokenAddress = web3js.utils.toChecksumAddress(process.env.ERC1155_CONTRACT_ADDRESS);

    // ether 단위 정보 - 참고 : https://web3js.readthedocs.io/en/v1.5.2/web3-utils.html?highlight=toHex#tohex
    const amount = web3js.utils.toWei('220', 'wei');

    const chainId = await web3js.eth.getChainId();

    // 개인 키로 거래에 서명
    const signedTx  = await web3js.eth.accounts.signTransaction({
        "to": erc1155TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
        "gas": 91712,
        "chainId": chainId,
        "value":"0x0",
        "data": contract.methods.sendToken(from, to, 0, amount).encodeABI()
    }, token_master_pk)
    console.log("signedTx : ",signedTx.rawTransaction);

    // 트랜잭션 전송
    web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
        .once("transactionHash", hash => {
            // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
            console.info("transactionHash: ", "https://ropsten.etherscan.io/tx/" + hash)
        })
        .once("receipt", receipt => {
            console.log("거래 후 토큰 정보");
            contract.methods.getBalance(token_master, 0).call().then(function(str) {
                console.log("token_master.getBalance(): ",str);
            });
            contract.methods.getBalance(address, 0).call().then(function(str) {
                console.log("address.getBalance(): ",str);
            });
        })
        .on("error: ", console.error)
}


const erc20Send = async () => {
    // const chainId = await web3js.eth.getChainId();
    // console.log("거래 전 토큰 정보");
    // await contract.methods.getBalance(token_master).call().then(function(str) {
    //     console.log("token_master.getBalance(): ",str);
    // });
    // await contract.methods.getBalance(address).call().then(function(str) {
    //     console.log("address.getBalance(): ",str);
    // });
    //
    // // ERC20 토큰 전송
    // const from = web3js.utils.toChecksumAddress(token_master);
    // const to = web3js.utils.toChecksumAddress(address);
    // const erc20TokenAddress = web3js.utils.toChecksumAddress(erc20ContractAddress);
    // const amount = web3js.utils.toWei('220', 'ether');
    //
    // // 개인 키로 거래에 서명
    // const signedTx  = await web3js.eth.accounts.signTransaction({
    //     "to": erc20TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
    //     "gas": 41712,
    //     "chainId": chainId,
    //     "value":"0x0",
    //     "data": contract.methods.transfer(to, amount).encodeABI()
    // }, token_master_pk)
    // console.log("signedTx : ",signedTx.rawTransaction);
    //
    // // 트랜잭션 전송
    // web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
    //     .once("transactionHash", hash => {
    //         // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
    //         console.info("transactionHash: ", "https://ropsten.etherscan.io/tx/" + hash)
    //     })
    //     .once("receipt", receipt => {
    //         console.log("거래 후 토큰 정보");
    //         contract.methods.getBalance(token_master).call().then(function(str) {
    //             console.log("token_master.getBalance(): ",str);
    //         });
    //         contract.methods.getBalance(address).call().then(function(str) {
    //             console.log("address.getBalance(): ",str);
    //         });
    //     })
    //     .on("error: ", console.error)
}

// 파일 ipfs 업로드하는 함수
const ipfsUpload = async (req, res, next) => {
    try {
        // console.log("req: ",req);

        // (시나리오) 1. 이미지 ipfs 저장 후 경로 호출 -> 2. json 파일 생성 -> 3. nft 생성


        // 1. 이미지 ipfs 저장 후 경로 호출
        // pinFileToIPFS


        // 2. 메타데이터 정보가 담긴 json 파일 생성

         // 메타데이터 구조
         // "id": 0,
         // "name": "Asset Name", // 콘텐츠명(작품명)
         // "image" (이미지) :  "ipfs://YOUR_ASSET_CID" // NFT의 디지털 자산에 대한 링크인 문자열
         // "description": "description...", // NFT의 설명을 저장하는 문자열
         // "properties": { //  { 구매자, 가격 }
         //    "creator": "creator name", // 창작자명
         //    "create_date": "2020-05-20", // 등록일자
         //    "total_token": "5", // 총 복제 수량
         //    "file_name": "myContent.dat", // 콘텐츠 파일명
         //    walletAddress - 사용자의 지갑 주소를 저장하는 문자열
         //    status- UI 하단에 표시할 메시지가 포함된 문자열
         // }

const attributesJson = `{ "creator" : "creator name", "create_date" : "2020-05-20", "total_token" : "5", "file_name" : "myContent.dat" }` ;

let metaDataInfo = new Map();
metaDataInfo.set("name", "Asset Name");
metaDataInfo.set("image", "ipfs://YOUR_ASSET_CID");
metaDataInfo.set("description", "description");
metaDataInfo.set("attributes", attributesJson);

// map -> Json 변환
// 참고 : https://velog.io/@kwonh/ES6-%EB%8D%B0%EC%9D%B4%ED%84%B0%EC%BB%AC%EB%A0%89%EC%85%984-Map%EC%9C%BC%EB%A1%9C-%EA%B0%9D%EC%B2%B4-%EB%8C%80%EC%8B%A0%ED%95%98%EA%B8%B0
const modified = [...metaDataInfo]
const reducerApplied = modified.reduce((accum,current)=>{
    return {
        ...accum,
        [current[0]]:current[1]
    }
},{})
console.log("reducerApplied: ", reducerApplied);
let json = JSON.stringify(reducerApplied);

let isId = 2;

// 비동기방식으로 json 파일 저장 (writeFile, createWriteStream, writeFileSync)
fs.writeFile(`./json/${isId}.json`, json, 'utf8', (err) => {
    if (err) throw err;
    console.log('The file has been saved!');
    let data2 = fs.readFileSync(`./json/${isId}.json`,'utf-8');
    console.log('data2: ',data2);



    // const resilt = await fs.writeFile('./json/myjsonfile.json', json);
    //  console.log("resilt: ", resilt);
    // IPFS 서버에 json 파일 생성
    // const jsonResult = await pinJSONToIPFS(reducerApplied);
    // console.log("jsonResult: ","https://ipfs.io/ipfs/"+jsonResult);

    // pinFileToIPFS
    // const jsonResult = await pinFileToIPFS(reducerApplied);
    // console.log("jsonResult: ","https://ipfs.io/ipfs/"+jsonResult);

    // json 파일 정보 조회
    // const pinResult = await pinCheck(jsonResult);
    // console.log("pinResult: ",pinResult);
    // console.log("pinResult.name: ",pinResult.name);
    // console.log("pinResult.image: ",pinResult.image);
    // console.log("pinResult.description: ",pinResult.description);
    // console.log("pinResult.attributes: ",pinResult.attributes);

    // string -> json 변환 - 참고 : https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse
    // const parsedData = JSON.parse(pinResult.attributes);
    // console.log("parsedData: ",parsedData);

    res.status(200).json({
        message: 'ipfsUpload 파일 업로드 완료!'
    })
});

} catch (err) {
    console.err("ipfs 파일 업로드 에러 : ", err);
}
}

*/



module.exports = {
    auctionCreate,
    auctionList,
    auctionDetail,
    auctionBid,
    auctionEnd,
}