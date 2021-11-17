const { vodModel } = require('../models')


// 영상통화 목록 조회
const vodList = async (userInfo) => {
    //console.log("vodList 실행: "+foundUser)
    const foundUser = await vodModel.vodList(userInfo)
    return foundUser
}


// 영상통화 내용 생성
const videoCallCreate = async (userInfo) => {
    const foundUser = await vodModel.videoCallCreate(userInfo)
    return foundUser
}


module.exports = {
    vodList,
    videoCallCreate,
}