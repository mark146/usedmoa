const dotenv = require('dotenv').config()
const {VodService} = require('../services')
const {Auth} = require('../middlewares')
const AWS = require("aws-sdk");
const uuid = require("uuid");
const fs = require('fs');
require('date-utils')


AWS.config.update({ region: process.env.Region });


// 참고 https://ichi.pro/ko/ipfslo-erc-721-nftleul-guchughaneun-bangbeob-254443020417300
const S3_BUCKET = process.env.VodBucketName;
const s3 = new AWS.S3({
    accessKeyId: process.env.AccessKeyId,
    secretAccessKey: process.env.SecretAccessKey,
    region: process.env.Region,
    signatureVersion: "v4"
});


// 영상통화 목록 - 참고 : https://cotak.tistory.com/83
const vodList = async (req, res, next) => {
    try {
        let accessToken = "";
        let userInfo = new Map();

        // 1. 값 추출
        // accessToken = req.headers.authorization.split('Bearer ')[1];
        // userInfo.set("accessToken", accessToken);
        // console.log("accessToken: " + accessToken);
        userInfo.set("user_id", req.query.user_id);
        console.log("vodList 실행: "+req.query.user_id)


        // 2. jwt 값 검증
        // await Auth.verifyJWT(accessToken)

        // 3. 글 목록 조회
        const result = await VodService.vodList(userInfo);
        console.log(`result: `,result);


        // 4. 클라이언트 전달 - 새로 발급한 access token과 원래 있던 refresh token 모두 클라이언트에게 반환합니다.
        res.status(200).json({
            statusCode : 200,
            list : result,
        })
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


// vod 파일 s3 업로드하는 함수
const vodUpload = async (req, res, next) => {
    try {
        let userInfo = new Map();

        // 1. 값 추출
        const url = req.body.url
        const words = url.split('/');
        const filePath = Array();
        userInfo.set("create_user", req.body.create_user);
        userInfo.set("board_id", req.body.board_id);
        console.log("vodUpload - req: ",req.body)
        console.log("vodUpload - url: ",req.body.url)
        console.log("vodUpload - create_user: ",req.body.create_user)
        console.log("vodUpload - board_id: ",req.body.board_id)


        // 파일 경로 수정(문자열 자르기, 합치기)
        for(var i=3; i<7; i++) {
            switch (i) {
                case 3:
                    filePath.push("/opt/"+words[i]+"/")
                    break;
                case 6:
                    filePath.push(words[i])
                    break;
                default:
                    filePath.push(words[i]+"/")
            }
        }
        const result = filePath.join('');
        console.log("vodUpload - filePath: ",result)

        // Directory 존재 여부 체크, 디렉토리 경로 입력
        const directory = fs.existsSync(result)


        // 2. s3 파일 업로드, Directory가 존재 할 경우 true, 없을 경우 false
        if(directory == true) {
            //console.log("Boolan : ", directory);
            const fileName = uuid.v4();
            const fileContent = fs.readFileSync(result);
            const s3Params = {
                Bucket: S3_BUCKET,
                Key: fileName + ".mp4",
                Body: fileContent,
                ACL: 'public-read',
                ContentType: "video/mp4"
            };
            s3.upload(s3Params, async function (err, data) {
                if (err) {
                    console.error("s3.upload - err: ",err);

                    return res.status(500).json({
                        statusCode : 500,
                        message: 'vod upload error!'
                    })
                }
                console.log(`data.Location: ${data.Location}`);
                userInfo.set("video_url", data.Location);


                // 3. 영상통화 내용 저장
                const response = await VodService.videoCallCreate(userInfo)
                console.log(`s3 파일 업로드 성공: ${response}`);

                res.status(200).json({
                    statusCode : 200,
                    message: 's3 파일 업로드 완료!'
                })
            });
        }
    } catch (err) {
        console.error("s3 파일 업로드 에러 : ", err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


module.exports = {
    vodList,
    vodUpload,
}