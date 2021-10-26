/*
그리고 정상적으로 토큰이 발급이 되었다면, 
이 토큰이 우리 서버의 토큰인지 확인할 일종의 '검문소'가 필요하겠죠? 
express에서는 서버로 오는 매 요청마다 기본적으로 적용할 기능을 설정할 수 있는 
middleware라는 것이 존재합니다. 
우리 서버로 오는 요청마다 기본적으로 체크할 수 있으면 더욱 좋겠죠? 
그래서 토큰을 검증하는 기능을 middleware로 구축했습니다.
미들웨어를 구현하고 나면 
아래와 같이 요청을 보내면,위에서 정의한 verifyJWT를 사용하여 검증을 먼저 한 후
통과한다면 정상적으로 실행
*/
// 참고 : https://victorydntmd.tistory.com/116
const dotenv = require('dotenv').config()
const jwt = require("jsonwebtoken");

const SECRET_KEY = process.env.SECRET_KEY;


const createJWT = async (userInfo) => {
    console.log(`createJWT 실행`)
    
    // access token 발급
    const accessToken = jwt.sign({
        user_id: userInfo.get('id') // 토큰의 내용(payload)
    },
    SECRET_KEY, // 비밀 키
    {
        algorithm: 'HS256', // 암호화 알고리즘
        expiresIn: '5m' // 유효 시간: 5분
    })
    userInfo.set("accessToken", accessToken)
    // console.log(`accessToken: ${accessToken}`)


    // refresh token 발급
    const refresh = jwt.sign({
        user_id: userInfo.get('id') // 토큰의 내용(payload)
    }, SECRET_KEY, { // refresh token은 payload 없이 발급
        algorithm: 'HS256',
        expiresIn: '15d',
    });
    userInfo.set("refreshToken", refresh)
    // console.log(`refreshToken: ${refresh}`)

    return userInfo
}


// jwt 값 검증
const verifyJWT = async (accessToken) => {
    console.log(`verifyJWT 실행`)

    try {
        // verify(전달받은 토큰, 생성시 입력한 salt값)
        var decode = jwt.verify(accessToken, process.env.SECRET_KEY)
        console.log(`verifyJWT - decode: ${decode}`)

        return decode
    } catch (err) {
        console.log(`error.name: ${err.name}`)
        if (err.name === 'TokenExpiredError') {
            // 에러 : 토큰이 기간만료 되었을 때 처리
        }
        // 에러 : 유효하지 않은 토큰일 때의 처리
    }
}


module.exports = {
    createJWT,
    verifyJWT,
}