// endpoint에 해당하는 처리 로직 담당(request에 대한 error handling 및 response)
const UserModel = require('./userModel')
const BoardModel = require('./boardModel')
const AuctionModel = require('./auctionModel')
const VodModel = require('./vodModel')


module.exports = {
    UserModel,
    BoardModel,
    AuctionModel,
    VodModel,
}