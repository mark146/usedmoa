const { boardModel } = require('../models')


// 글 목록 조회
const boardList = async (userInfo) => {
    // console.log("BoardService - userInfo: ",userInfo);
    const foundUser = await boardModel.boardList(userInfo)
    return foundUser
}


// 글 생성
const boardCreate = async (userInfo) => {
    const foundUser = await boardModel.boardCreate(userInfo)
    return foundUser
}


module.exports = {
    boardList,
    boardCreate,
}