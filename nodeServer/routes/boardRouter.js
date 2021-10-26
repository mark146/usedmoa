const express = require('express')
const router = express.Router()
const {boardController} = require('../controllers')


// 핸들링 하는 컨트롤러 함수
router.get('/list', boardController.boardList)
router.post('/create', boardController.boardCreate)
router.post('/generatePresignedUrl', boardController.getPresignedUrl)


// 부모 router 연결
module.exports = router