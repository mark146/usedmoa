const express = require('express')
const router = express.Router()
const {vodController} = require('../controllers')


// 핸들링 하는 컨트롤러 함수
router.get('/list', vodController.vodList)
router.post('/upload', vodController.vodUpload)


// 부모 router 연결
module.exports = router