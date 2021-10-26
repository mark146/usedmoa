const express = require('express');
const router = express.Router();
const userRouter = require('./userRouter')
const boardRouter = require('./boardRouter')
const auctionRouter = require('./auctionRouter')
const vodRouter = require('./vodRouter')


// 핸들링 하는 컨트롤러 함수
router.use('/auction', auctionRouter);
router.use('/board', boardRouter);
router.use('/users', userRouter);
router.use('/vod', vodRouter);


// express app의 미들웨어로 사용
module.exports = router;