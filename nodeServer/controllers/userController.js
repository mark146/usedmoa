const dotenv = require('dotenv').config()
const { userService } = require('../services')
const { auth } = require('../middlewares')
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
      userInfo.set("walletAddress", req.body.wallet_address);
      console.log(`logIn - accessToken: ${accessToken}`);
      console.log(`logIn - walletAddress: ${req.body.wallet_address}`);

      // 2. 카카오톡 Access Token 검증
      await userService.kakaoTokenCheck(userInfo)
      console.log(`kakaoTokenCheck - userInfo.get(id): ${userInfo.get("id")}`);

      // 3. id 값이 -1 일 경우 엑세스 토큰 에러
      if (userInfo.get("id") == -1) {
        return res.status(401).json({
          error: 'Auth Error from accessToken'
        });
      } else {
        // 4. 카카오톡 사용자 정보 조회
        await userService.getUserInfo(userInfo);
        // console.log(`getUserInfo - userInfo: ${userInfo.size}`);

        // 5. DB 사용자 정보 조회
        await userService.findUser(userInfo)

        // 7. 사용자 유무 체크
        let message = "";
        let walletAddress = "";
        if (userInfo.get("user_id") === undefined) { // 사용자가 없을 경우
          // 사용자 생성
          await userService.userCreate(userInfo)

          // access, refresh token 발급
          await auth.createJWT(userInfo)

          // refresh token 업데이트
          await userService.userUpdate(userInfo)

          message = 'user create';
          walletAddress = "";
        } else { // 사용자가 있을 경우
          // access, refresh token 발급
          await auth.createJWT(userInfo)

          // refresh token 업데이트
          await userService.userUpdate(userInfo)

          message = 'user update';
          walletAddress = userInfo.get("walletAddress");
        }

        // 8. 클라이언트 전달 - 새로 발급한 access token과 원래 있던 refresh token 모두 클라이언트에게 반환합니다.
        res.setHeader("accessToken", userInfo.get("accessToken"))
        res.setHeader("refreshToken", userInfo.get("refreshToken"))
        res.status(200).json({
          email: userInfo.get("email"),
          user_id: userInfo.get("user_id"),
          walletAddress: walletAddress,
          message: message,
        })
      }
    } else {
      res.status(401).json({
        error: 'Auth Error from authorization'
      });
    }
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      error: err.message
    });
  }
}


/**
 access, refresh Token 재발급
 case1: access token과 refresh token 모두가 만료된 경우 -> 에러 발생
 case2: access token은 만료됐지만, refresh token은 유효한 경우 ->  access token 재발급
 case3: access token은 유효하지만, refresh token은 만료된 경우 ->  refresh token 재발급
 case4: accesss token과 refresh token 모두가 유효한 경우
 */
const refresh = async (req, res, next) => {
  console.log(`refresh 실행`);

  try {
    if (req.headers.authorization) { // Token 값 체크

      // 1. 값 추출
      let userInfo = new Map();
      userInfo.set("accessToken", req.headers.authorization.split('Bearer ')[1]);
      userInfo.set("refreshToken", req.cookies.refresh);
      //console.log("req.cookies: " + JSON.stringify(req.cookies));


      // 2. 토큰 검증
      let accessToken = await auth.verify(userInfo);
      let refreshToken = await auth.refreshVerify(userInfo);
      // console.log("accessToken: ",accessToken);
      // console.log("refreshToken: ",refreshToken);


      // 엑세스 토큰 체크
      switch (accessToken) {
        case "TokenExpiredError" : // 엑세스 토큰이 만료된 경우

          // 리프래시 토큰 체크
          switch (refreshToken) {
            case "TokenExpiredError" : // 리프래시 토큰이 만료된 경우

              // 3. 사용자 리프레시 토큰 정보 조회
              refreshToken = await userService.refreshVerify(userInfo);
              console.log("refreshToken: ",refreshToken);
              console.log("userInfo.get(user_id): ",userInfo.get("user_id"));

              // 회원이 아닐 경우 에러 처리
              if(userInfo.get("user_id") === undefined) {
                return res.status(401).json({
                  error: 'Auth Error from authorization'
                })
              } else {

                // 토큰 재발급
                await auth.createJWT(userInfo);

                // 새로 발급받은 토큰 정보 저장
                await userService.userUpdate(userInfo);
                // console.log(`result - accessToken: ${userInfo.get("accessToken")}`);
                // console.log(`result - refreshToken: ${userInfo.get("refreshToken")}`);

                // 클라이언트 전달 - 새로 발급한 access token과 원래 있던 refresh token 모두 클라이언트에게 반환합니다.
                res.setHeader("accessToken", userInfo.get("accessToken"))
                res.setHeader("refreshToken", userInfo.get("refreshToken"))
                return res.status(200).json({
                  message: 'Token 재발급 완료',
                })
              }
              break;
            default:

              // 사용자 리프레시 토큰 정보 조회
              refreshToken = await userService.refreshVerify(userInfo);
              console.log("refreshToken: ",refreshToken);
              console.log("userInfo.get(user_id): ",userInfo.get("user_id"));

              // 회원이 아닐 경우 에러 처리
              if(userInfo.get("user_id") === undefined) {
                return res.status(401).json({
                  error: 'Auth Error from authorization'
                })
              } else {
                // 액세스 토큰 재발급
                await auth.createAccessToken(userInfo);
                console.log("userInfo.get(accessToken): ",userInfo.get("accessToken"));

                res.setHeader("accessToken", userInfo.get("accessToken"))
                return res.status(200).json({
                  message: '액세스 토큰 재발급 완료',
                })
              }
          }
          break;
        case undefined :
          res.status(200).json({
            message: '엑세스 토큰 기간이 유효합니다.'
          });
          break;
        default: // todo - 다른 에러 처리
          res.status(401).json({
            error: 'Auth Error from authorization'
          });
      }
    } else {
      res.status(401).json({
        error: 'Auth Error from authorization'
      });
    }
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      error: err.message
    });
  }
}


// 경매물품 결제 (블록체인 토큰)
const payment = async (req, res, next) => {
  try {
    let accessToken = "";
    let userInfo = new Map();
    userInfo.set("auctionId", req.body.auctionId);
    userInfo.set("money", req.body.money);

    // todo - 실제 사용자 메타마스크 주소로 처리 예정
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

    // 비즈니스 로직 처리
    await userService.payment(userInfo);

    res.status(200).json({
      message: 'payment 실행 완료',
    })
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      error: err.message
    });
  }
}


// 상품 결제 (블록체인 토큰)
const itemPayment = async (req, res, next) => {
  try {
    let accessToken = "";
    let userInfo = new Map();


    // Access Token 값 체크
    if (req.headers.authorization) {

      // 값 추출
      accessToken = req.headers.authorization.split('Bearer ')[1];
      userInfo.set("accessToken", accessToken);
      userInfo.set("board_id", req.body.board_id);
      console.log("accessToken: " + userInfo.get("accessToken"));
      console.log("board_id: " + userInfo.get("board_id"));


      // todo - 엑세스 토큰 검증


      // 비즈니스 로직 처리
      await userService.itemPayment(userInfo);

      // 클라이언트 전달 - 새로 발급한 access token과 원래 있던 refresh token 모두 클라이언트에게 반환합니다.
      res.status(200).json({
        "message": "상품 결제가 완료되었습니다."
      })
    } else {
      res.status(401).json({
        error: 'Auth Error from authorization'
      });
    }
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      error: err.message
    });
  }
}


// 사용자 보유 토큰 정보 조회
const balance = async (req, res, next) => {
  console.log("balance 실행")

  try {
    if (req.headers.authorization) { // Token 값 체크
      // 1. 값 추출
      let userInfo = new Map();
      userInfo.set("accessToken", req.headers.authorization.split('Bearer ')[1]);
      console.log("userInfo.get(accessToken): ", userInfo.get("accessToken"));

      // 2. 토큰 검증
      let isAccessToken = await auth.verify(userInfo);
      console.log("isAccessToken: ", isAccessToken)

      // 토큰 값이 만료되거나 이상할 경우 에러값 전달
      if (isAccessToken == "TokenExpiredError" || isAccessToken == "JsonWebTokenError") {
        return res.status(401).json({
          error: 'Auth Error from accessToken'
        });
      } else {
        userInfo.set("walletAddress", req.query.walletAddress);
        console.log("walletAddress: ", userInfo.get("walletAddress"));

        // 비즈니스 로직 실행
        const result = await userService.balance(userInfo)

        res.status(200).json({
          amount : result
        })
      }
    }
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      error: err.message
    });
  }
}


// todo - 유저 거래내역 조회 (미완성)
const tradeHistory = async (req, res, next) => {
  try {
    let accessToken = "";
    let userInfo = new Map();


    // todo - 실제 사용자 메타마스크 주소로 처리 예정
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

    // 비즈니스 로직 실행
    const result = await userService.tradeHistory(userInfo);

    res.status(200).json({
      historyList : result
    })
  } catch (err) {
    console.error("err: ",err);

    res.status(500).json({
      error: err.message
    });
  }
}


module.exports = {
  login,
  itemPayment,
  payment,
  balance,
  tradeHistory,
  refresh,
}