const dotenv = require('dotenv').config()
const jwt = require("jsonwebtoken");


// 리프래시, 액세스 토큰 발급
const createJWT = async (userInfo) => {
    console.log(`createJWT 실행`)
    console.log(`userInfo.get('user_id'): `, userInfo.get('user_id'))

    // 토큰의 내용(payload) : 사용자 이름, 사용자 역할 등과 같은 사용자에 대한 정보를 저장
    let payload = {
        user_id: userInfo.get('user_id')
    }

    // access token 발급
    const accessToken = jwt.sign(payload,
        process.env.ACCESS_TOKEN_SECRET, { // 비밀 키
            algorithm: 'HS256', // 암호화 알고리즘
            expiresIn: process.env.ACCESS_TOKEN_LIFE
        })
    userInfo.set("accessToken", accessToken)
    // console.log(`accessToken: ${accessToken}`)


    // refresh token 발급
    const refresh = jwt.sign({},
        process.env.REFRESH_TOKEN_SECRET, { // 비밀 키
            algorithm: 'HS256', // 암호화 알고리즘
            expiresIn: process.env.REFRESH_TOKEN_LIFE,
        });
    userInfo.set("refreshToken", refresh)
    // console.log(`refreshToken: ${refresh}`)

    return userInfo
}


// 액세스 토큰 발급
const createAccessToken = async (userInfo) => {
    console.log(`createAccessToken 실행`)

    // 토큰의 내용(payload) : 사용자 이름, 사용자 역할 등과 같은 사용자에 대한 정보를 저장
    let payload = { user_id: userInfo.get('user_id') }

    // access token 발급
    const accessToken = jwt.sign(payload,
        process.env.ACCESS_TOKEN_SECRET, { // 비밀 키
            algorithm: 'HS256', // 암호화 알고리즘
            expiresIn: process.env.ACCESS_TOKEN_LIFE
        })
    userInfo.set("accessToken", accessToken)
    return userInfo
}


// refresh token 검증
const verify = async (userInfo) => {
    console.log(`verify 실행`)
    const accessToken = userInfo.get("accessToken");

    let payload
    try {
        // jwt.verify 메서드를 사용하여 액세스 토큰을 확인합니다.
        payload = jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET)
        console.log(`verify - JSON.stringify(payload): ${JSON.stringify(payload)}`)

        return payload.user_id;
    } catch (err) {
        console.log(`verify - error.name: ${err.name}`)
        //오류가 발생한 경우 반환 요청 승인되지 않은 오류 반환
        return err.name
    }
}


// refresh token 검증
const refreshVerify = async (userInfo) => {
    console.log(`refreshVerify 실행`)
    const refreshToken = userInfo.get("refreshToken");

    try{
        return jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET)
    } catch(err) {
        console.log(`refreshVerify - error: ${err.name}`)
        return err.name
    }
}


module.exports = {
    createJWT,
    verify,
    refreshVerify,
    createAccessToken,
}