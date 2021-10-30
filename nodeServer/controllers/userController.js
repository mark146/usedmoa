const dotenv = require('dotenv').config()
const {userService} = require('../services')
const {auth} = require('../middlewares')
require('date-utils')


// 로그인 & 회원가입
const login = async (req, res, next) => {
  try {
    let accessToken = "";
    let userInfo = new Map();

    // Access Token 값 체크
    if (req.headers.authorization) {

      // 1. 값 추출
      accessToken = req.headers.authorization.split('Bearer ')[1];
      userInfo.set("accessToken", accessToken);
      //console.log(`logIn - accessToken: ${accessToken}`);

      // 2. 카카오톡 Access Token 검증
      await userService.kakaoTokenCheck(userInfo)
      console.log(`kakaoTokenCheck - userInfo: ${userInfo.size}`);

      // 3. userInfo 크기가 2 일 경우 토큰 재확인
      if (userInfo.size == 2) {
        return res.status(401).json({ error: 'Auth Error from accessToken' });
      } else {
        // 4. 사용자 정보 조회
        await userService.getUserInfo(userInfo);
        // console.log(`getUserInfo - userInfo: ${userInfo.size}`);

        // 5. access token 발급
        await auth.createJWT(userInfo)

        // 6. db에 유저 정보 조회
        await userService.findUser(userInfo)

        // 7. 사용자가 없을 경우 생성, 있을 경우 정보 업데이트
        if (userInfo.get("user_id") === undefined) {
          await userService.userCreate(userInfo)
        } else {
          await userService.userUpdate(userInfo)
        }

        // 8. 클라이언트 전달 - 새로 발급한 access token과 원래 있던 refresh token 모두 클라이언트에게 반환합니다.
        res.setHeader("accessToken", userInfo.get("accessToken"))
        res.setHeader("refreshToken", userInfo.get("refreshToken"))
        res.status(200).json({
          statusCode : 200,
          email: userInfo.get("email"),
          user_id: userInfo.get("user_id"),
          message: 'user created',
        })
      }
    } else {
      res.status(401).json({
        statusCode : 401,
        error: 'Auth Error from authorization'
      });
    }
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      statusCode : 500,
      error: err.message
    });
  }
}


// 블록체인 토큰 결제
const payment = async (req, res, next) => {
  try {
    let accessToken = "";
    let userInfo = new Map();
    userInfo.set("auctionId", req.body.auctionId);
    userInfo.set("money", req.body.money);


    switch (req.body.userId) {
      case "master":
        userInfo.set("userAddress", process.env.TOKEN_MASTER_ADDRESS);
        break
      case "user_v1":
        userInfo.set("userAddress", process.env.USER_V1_ADDRESS);
        break
      case "user_v2":
        userInfo.set("userAddress", process.env.USER_V2_ADDRESS);
        break
      default:
        console.log("default: ",req.query.userId);
    }
    console.log("userInfo: ", userInfo)


    await userService.payment(userInfo);


    res.status(200).json({
      statusCode : 200,
      message: 'payment 실행 완료',
    })
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      statusCode : 500,
      error: err.message
    });
  }
}


// 블록체인 토큰 정보 조회
const tokenAmount = async (req, res, next) => {
  try {
    let accessToken = "";
    let userInfo = new Map();
    userInfo.set("auctionId",req.query.userId);


    switch (req.query.userId) {
      case "master":
        userInfo.set("userAddress", process.env.TOKEN_MASTER_ADDRESS);
        break
      case "user_v1":
        userInfo.set("userAddress", process.env.USER_V1_ADDRESS);
        break
      case "user_v2":
        userInfo.set("userAddress", process.env.USER_V2_ADDRESS);
        break
      default:
        console.log("default: ",req.query.userId);
    }
    console.log("userInfo: ", userInfo)


    const result = await userService.tokenAmount(userInfo)


    res.status(200).json({
      statusCode : 200,
      amount : result
    })
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      statusCode : 500,
      error: err.message
    });
  }
}


// 유저 거래내역 조회
const tradeHistory = async (req, res, next) => {
  try {
    let accessToken = "";
    let userInfo = new Map();


    switch (req.query.userId) {
      case "master":
        userInfo.set("userAddress", process.env.TOKEN_MASTER_ADDRESS);
        break
      case "user_v1":
        userInfo.set("userAddress", process.env.USER_V1_ADDRESS);
        break
      case "user_v2":
        userInfo.set("userAddress", process.env.USER_V2_ADDRESS);
        break
      default:
        console.log("default: ",req.query.userId);
    }
    console.log("userInfo: ", userInfo)


    const result = await userService.tradeHistory(userInfo);


    res.status(200).json({
      statusCode : 200,
      historyList : result
    })
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      statusCode : 500,
      error: err.message
    });
  }
}


module.exports = {
  login,
  payment,
  tokenAmount,
  tradeHistory,
}