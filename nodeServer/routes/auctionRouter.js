const express = require('express')
const router = express.Router()
const {auctionController} = require('../controllers')
const {fileUpload} = require('../middlewares')
const path = require("path");
const multer  = require('multer');
require('date-utils')


// 이미지 업로드 처리
const storage = multer.diskStorage({
    destination: './images',
    filename: function (request, file, callback) {

        /* 확장자를 제외한 파일명 */
        /* 파일의 중복과 덮어쓰기를 방지하기 위해 시간을 붙인다 */
        callback(null, Date.now() + '_' + path.extname(file.originalname))
    }
})

const upload = multer( {
    storage: storage,
    limits: {
        files: 10, /* 한번에 업로드할 최대 파일 개수 */
        fileSize: 1024 * 1024 * 10 /* 업로드할 파일의 최대 크기 */
    }
});


// 핸들링 하는 컨트롤러 함수
router.get('/list', auctionController.auctionList)
router.get('/detail', auctionController.auctionDetail)
router.post('/create', upload.array('uploadfile'), auctionController.auctionCreate)
router.post('/bid', auctionController.auctionBid)
router.post('/end', auctionController.auctionEnd)


// 부모 router 연결
module.exports = router