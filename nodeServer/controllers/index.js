const userController = require('./userController')
const boardController = require('./boardController')
const auctionController = require('./auctionController')
const vodController = require('./vodController')


// express app의 미들웨어로 사용
module.exports = {
  userController,
  boardController,
  auctionController,
  vodController,
}