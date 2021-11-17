// controller로부터 받은 인자 기반 data 가공 비즈니스 로직 담당
const userService = require('./userService')
const boardService = require('./boardService')
const auctionService = require('./auctionService')
const vodService = require('./vodService')


module.exports = {
  userService,
  boardService,
  auctionService,
  vodService,
}