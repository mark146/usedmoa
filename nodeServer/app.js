// Express 애플리케이션의 설정을 담당하는 파일
const express = require('express')
const router = require('./routes/routes')
const cors = require('cors');
const server = express()


server.use(cors()); // CORS 방식 허용
server.use(express.json()) // json 형태로 parsing
server.use(express.urlencoded({ extended: true })) // 따로 설치가 필요한 qs 모듈을 사용하여 쿼리 스트링을 해석


// Route 의존성 설정
server.use(router)


// 서버 포트 오픈
server.listen(process.env.SERVER_PORT, () => {
    console.log('Server is running on port 3000')
})