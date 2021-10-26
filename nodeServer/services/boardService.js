const { BoardModel } = require('../models')


// 글 목록 조회
const boardList = async (userInfo) => {
    // console.log("BoardService - userInfo: ",userInfo);
    const foundUser = await BoardModel.boardList(userInfo)
    return foundUser
}


// 글 생성
const boardCreate = async (userInfo) => {
    const foundUser = await BoardModel.boardCreate(userInfo)
    return foundUser
}


// 영상통화 목록 조회
const vodList = async (userInfo) => {
    const foundUser = await BoardModel.vodList(userInfo)
    return foundUser
}


module.exports = {
    boardList,
    boardCreate,
    vodList,
}