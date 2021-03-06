const express = require('express')
const router = express.Router()
const {userController} = require('../controllers')


// 핸들링 하는 컨트롤러 함수
router.post('/refresh', userController.refresh)
router.post('/logIn', userController.login)
router.post('/payment', userController.payment)
router.post('/itemPayment', userController.itemPayment)
router.get('/balance', userController.balance)
router.get('/tradeHistory', userController.tradeHistory)


// 부모 router 연결
module.exports = router