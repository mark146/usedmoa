const { UserModel, BoardModel } = require('../models')
const axios = require("axios");
const dotenv = require('dotenv').config();
const Web3 = require('web3');
const fs = require("fs");
const web3js = new Web3(
    new Web3.providers.HttpProvider('https://ropsten.infura.io/v3/' + process.env.INFURA_KEY)
);
const erc1155Abi = JSON.parse(fs.readFileSync('/usr/local/nodejs/abi/erc1155_abi.json', 'utf-8'));
const contract = new web3js.eth.Contract(erc1155Abi, process.env.ERC1155_CONTRACT_ADDRESS);


// 카카오톡 토큰 체크하는 함수
const kakaoTokenCheck = async (userInfo) => {
  try {
    // 토큰 정보 확인: 액세스 토큰의 유효성을 검증하거나 정보를 확인하는 API
    // 토큰 만료 여부나 유효기간을 알 수 있어 갱신 과정에 활용
    const instance = axios.create({
      baseURL: 'https://kapi.kakao.com',
      headers: {
        Authorization: `Bearer ${userInfo.get('accessToken')}` // 사용자 인증 수단, 액세스 토큰 값
      }, timeout: 1000,
    })
    await instance.get('/v1/user/access_token_info', { timeout: 5000 })
        .then((res) => {
          // 결과값 - id : 회원번호, expires_in : 액세스 토큰 만료 시간(초), app_id : 토큰이 발급된 앱 ID
          userInfo.set('id', res.data.id)
          userInfo.set('expires_in', res.data.expires_in)
          userInfo.set('app_id', res.data.app_id)
          // console.log("access_token_info.id: " + res.data.id);
          // console.log("expires_in: " + res.data.expires_in);
          // console.log("app_id: " + res.data.app_id);

          return userInfo
        })
  } catch (err) {
    // console.log("tokenCheckError: ", err);
    userInfo.set('id', 0)
    return userInfo
  }
}


// 카카오톡 유저 정보 호출하는 함수
const getUserInfo = async (userInfo) => {
  try {
    // 사용자 정보 가져오기 - 참고 : https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api#get-token-info
    let property_keys = ["properties.nickname", "properties.profile_image", "kakao_account.email"]
    const getUserInfo = axios.create({
      baseURL: 'https://kapi.kakao.com',
      headers: {
        'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
        Authorization: `Bearer ${userInfo.get("accessToken")}` // 사용자 인증 수단, 액세스 토큰 값
      }, timeout: 1000,
    })
    await getUserInfo.post('/v2/user/me', {
          property_keys: property_keys,
        }, {
          withCredentials: true,
        },
    ).then((res) => {
      // console.log("getUserInfo: " + JSON.stringify(res.data));
      userInfo.set("nickname", res.data.properties.nickname)
      userInfo.set("email" ,res.data.kakao_account.email);
      // console.log("nickname: " + res.data.properties.nickname);
      // console.log("email: " + res.data.kakao_account.email);

      return userInfo
    });
  } catch (err) {
    console.log("getUserInfo - Error: ", err.name);
    return userInfo
  }
}


// 유저 정보 수정
const userUpdate = async (userInfo) => {
  const foundUser = await UserModel.userUpdate(userInfo)
  return foundUser
}


// 유저 정보 조회
const findUser = async (userInfo) => {
  const foundUser = await UserModel.findUser(userInfo)
  return foundUser
}


// 유저 정보 생성
const userCreate = async (userInfo) => {
  const foundUser = await UserModel.userCreate(userInfo)
  return foundUser
}


// 토큰 결제
const payment = async (userInfo) => {
  console.log("service - payment 실행");
  // const foundUser = await UserModel.userUpdate(userInfo)


  // 경매 인덱스
  const auctionId = await auctionIdCheck();
  console.info("auctionId: ",auctionId);


  // 경매 정보 조회
  const auctionInfo = await getAuctionInfo(userInfo.get("auctionId"));
  console.info("auctionInfo: ",auctionInfo);


  // 토큰 정보 조회
  const tokenInfo = await getUserTokenInfo(userInfo.get("userAddress"));
  console.info("tokenInfo: ",tokenInfo);


  // erc1155mint(process.env.ERC1155_CONTRACT_ADDRESS, 0, 2000);
  // 결제 유저 정보 체크
  // auctionId, userId

  // 토큰 결제
  erc1155Send(userInfo.get("userAddress"), process.env.USER_V1_ADDRESS, 0, userInfo.get("money"))
      .then(function(str) {
        console.log("erc1155Send: ",str);
      });
}


// 토큰 정보 조회
const tokenAmount = async (userInfo) => {
  console.log("service - tokenAmount 실행");
  // const foundUser = await UserModel.userUpdate(userInfo)

  // 경매 정보 조회
  const tokenInfo = await getUserTokenInfo(userInfo.get("userAddress"));
  console.info("tokenInfo: ",tokenInfo);

  return tokenInfo;
}


// 거래내역 조회
const tradeHistory = async (userInfo) => {
  console.log("service - tradeHistory 실행");
  // const foundUser = await UserModel.userUpdate(userInfo)

  // 경매 정보 조회
  const history = await getTradeHistory(userInfo.get("userAddress"));
  console.info("history: ",history);

  return history;
}


/* ############################################################## */

// 사용자 보유 토큰 정보 조회
const getUserTokenInfo = async (user_address) => {
  return await contract.methods.getBalance(user_address, 0).call();
}

// 마지막에 등록된 경매 인덱스 정보 조회
const auctionIdCheck = async () => {
  return await contract.methods.auctionIdCheck().call();
}

// 거래 내역 조회
const getTradeHistory = async (user_address) => {
  return await contract.methods.userTradeHistory(user_address).call();
}

// 경매 정보 조회
const getAuctionInfo = async (auction_id) => {
  return await contract.methods.auctionCheck(auction_id).call();
}

// 토큰 전송
const erc1155Send = async (fromAddress, toAddress, tokenId, money) => {
  console.log("거래 전 토큰 정보");

  // 거래전 사인처리
  const from = web3js.utils.toChecksumAddress(fromAddress);
  const to = web3js.utils.toChecksumAddress(toAddress);
  const erc1155TokenAddress = web3js.utils.toChecksumAddress(process.env.ERC1155_CONTRACT_ADDRESS);
  const chainId = await web3js.eth.getChainId();

  // ether 단위 정보 - 참고 : https://web3js.readthedocs.io/en/v1.5.2/web3-utils.html?highlight=toHex#tohex
  const amount = web3js.utils.toWei(`${money}`, 'wei');


  // 개인 키로 거래에 서명
  const signedTx  = await web3js.eth.accounts.signTransaction({
    "to": erc1155TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
    "gas": 5000000,
    "chainId": chainId,
    "value":"0x0",
    "data": contract.methods.sendToken(from, to, tokenId, amount).encodeABI()
  }, process.env.TOKEN_MASTER_PK)
  console.log("signedTx : ",signedTx.rawTransaction);

  // 트랜잭션 전송
  web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
      .once("transactionHash", hash => {
        // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
        console.info("transactionHash: ", "https://ropsten.etherscan.io/tx/" + hash)
      })
      .once("receipt", receipt => {
        console.log("토큰 거래 완료");
      })
      .on("error: ", console.error)
}

// 토큰 발급
const erc1155mint = async (fromAddress, tokenId, money) => {
  console.log(`거래 전 토큰 정보 fromAddress: ${fromAddress}, tokenId: ${tokenId}, money: ${money}`);

  // 거래전 사인처리
  const from = web3js.utils.toChecksumAddress(fromAddress);
  const erc1155TokenAddress = web3js.utils.toChecksumAddress(process.env.ERC1155_CONTRACT_ADDRESS);
  const chainId = await web3js.eth.getChainId();

  // ether 단위 정보 - 참고 : https://web3js.readthedocs.io/en/v1.5.2/web3-utils.html?highlight=toHex#tohex
  const amount = web3js.utils.toWei(money, 'wei');


  // 개인 키로 거래에 서명
  const signedTx  = await web3js.eth.accounts.signTransaction({
    "to": erc1155TokenAddress,  // 거래가 전송되는 계정, 비어 있으면 거래가 계약을 생성
    "gas": 5000000,
    "chainId": chainId,
    "value":"0x0",
    "data": contract.methods.mintTokens(from, tokenId, money).encodeABI()
  }, process.env.TOKEN_MASTER_PK)
  console.log("signedTx : ",signedTx.rawTransaction);

  // 트랜잭션 전송
  web3js.eth.sendSignedTransaction(signedTx.rawTransaction)
      .once("transactionHash", hash => {
        // tx가 pending되는 즉시 etherscan에서 tx진행상태를 보여주는 링크를 제공
        console.info("transactionHash: ", "https://ropsten.etherscan.io/tx/" + hash)
      })
      .once("receipt", receipt => {
        console.log("토큰 거래 완료");
      })
      .on("error: ", console.error)
}


module.exports = {
  kakaoTokenCheck,
  getUserInfo,
  userUpdate,
  findUser,
  userCreate,
  payment,
  tokenAmount,
  tradeHistory,
}