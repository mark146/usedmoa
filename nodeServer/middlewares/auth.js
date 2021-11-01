const dotenv = require('dotenv').config()
const jwt = require("jsonwebtoken");


/*
우리 서버로 오는 요청마다 기본적으로 체크할 수 있도록 토큰을 검증하는 기능을 middleware로 구축
미들웨어를 구현하고 나면 아래와 같이 요청을 보내면,위에서 정의한 verifyJWT를 사용하여 검증을 먼저 한 후 통과한다면 정상적으로 실행
참고 : https://victorydntmd.tistory.com/116
*/
const createJWT = async (userInfo) => {
    console.log(`createJWT 실행`)

    // 토큰의 내용(payload) : 사용자 이름, 사용자 역할 등과 같은 사용자에 대한 정보를 저장
    let payload = { user_id: userInfo.get('user_id') }

    // access token 발급
    const accessToken = jwt.sign(payload,
        process.env.ACCESS_TOKEN_SECRET, { // 비밀 키
            algorithm: 'HS256', // 암호화 알고리즘
            expiresIn: process.env.ACCESS_TOKEN_LIFE
        })
    userInfo.set("accessToken", accessToken)
    // console.log(`accessToken: ${accessToken}`)


    // refresh token 은 payload 없이 발급
    const refresh = jwt.sign(payload,
        process.env.REFRESH_TOKEN_SECRET, { // 비밀 키
            algorithm: 'HS256', // 암호화 알고리즘
            expiresIn: process.env.REFRESH_TOKEN_LIFE,
        });
    userInfo.set("refreshToken", refresh)
    // console.log(`refreshToken: ${refresh}`)

    return userInfo
}


// jwt 값 검증
const verify = async (accessToken) => {

    let payload
    try {

        // 쿠키에 저장된 토큰이 없으면 요청이 승인되지 않음
        // if (!accessToken){
        //     return "isEmpty accessToken"
        // }

        // jwt.verify 메서드를 사용하여 액세스 토큰을 확인합니다.
        // 토큰이 만료되었거나 서명이 잘못된 경우 오류가 발생합니다.
        payload = jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET)
        console.log(`verify - payload: ${payload.user_id}`)
        console.log(`verify - JSON.stringify(payload): ${JSON.stringify(payload)}`)
    } catch (err) {
        console.log(`verify - error.name: ${err.name}`)
        //오류가 발생한 경우 반환 요청 승인되지 않은 오류 반환
        return err.name
    }
}


// refresh token 검증 후 엑세스 토큰 발급
const refreshVerify = async (userInfo) => {

    let payload
    try{
        payload = jwt.verify(userInfo.get("refreshToken"), process.env.REFRESH_TOKEN_SECRET)
        console.log(`refreshVerify - payload.user_id: ${payload.user_id}`)
        console.log(`refreshVerify - JSON.stringify(payload): ${JSON.stringify(payload)}`)

        // 토큰의 내용(payload) : 사용자 이름, 사용자 역할 등과 같은 사용자에 대한 정보를 저장
        let payload = { user_id: payload.user_id }

        // access token 발급
        const accessToken = jwt.sign(payload,
            process.env.ACCESS_TOKEN_SECRET, { // 비밀 키
                algorithm: 'HS256', // 암호화 알고리즘
                expiresIn: process.env.ACCESS_TOKEN_LIFE
            })
        userInfo.set("accessToken", accessToken)
    } catch(err) {
        console.log(`refreshVerify - error: ${err.name}`)
        return err.name
    }
}


module.exports = {
    createJWT,
    verify,
    refreshVerify,
}