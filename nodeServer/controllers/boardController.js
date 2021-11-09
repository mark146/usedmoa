const dotenv = require('dotenv').config();
const AWS = require("aws-sdk");
const uuid = require("uuid");
const {boardService} = require("../services");
const {auth} = require("../middlewares");


AWS.config.update({ region: process.env.Region });
const S3_BUCKET = process.env.ImageBucketName;
const s3 = new AWS.S3({
    accessKeyId: process.env.AccessKeyId,
    secretAccessKey: process.env.SecretAccessKey,
    region: process.env.Region,
    signatureVersion: "v4"
});


// 글 목록
const boardList = async (req, res, next) => {
    try {
        let accessToken = "";
        let userInfo = new Map();

        // 회원일 경우 검증
        if(req.headers.authorization != undefined) {

            // 값 추출
            accessToken = req.headers.authorization.split('Bearer ')[1];
            userInfo.set("accessToken", accessToken);
            console.log("accessToken: " + accessToken);

            // jwt 값 검증
            // await Auth.verifyJWT(accessToken)
        }


        // 3. 글 목록 조회
        const result = await boardService.boardList(userInfo);
        // console.log(`result: `,result);


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


// 글 생성
const boardCreate = async (req, res, next) => {
    try {
        let accessToken = "";
        let userInfo = new Map();


        // Access Token 값 체크
        if (req.headers.authorization) {

            // 1. 값 추출
            accessToken = req.headers.authorization.split('Bearer ')[1];
            userInfo.set("accessToken", accessToken);
            userInfo.set("user_id", req.body.user_id);
            userInfo.set("image_url", req.body.image_url);
            userInfo.set("title", req.body.title);
            userInfo.set("product_name", req.body.product_name);
            userInfo.set("product_price", req.body.product_price);
            userInfo.set("content", req.body.content);
            // console.log("user_id: " + req.body.user_id);
            // console.log("image_url: " + req.body.image_url);
            // console.log("title: " + req.body.title);
            // console.log("product_name: " + req.body.product_name);
            // console.log("product_price: " + req.body.product_price);
            // console.log("content: " + req.body.content);


            // 2. jwt 값 검증
            // let verify  = await auth.verify(accessToken)
            // console.log(`verify: `,verify)
            //
            // switch (verify) {
            //     case "TokenExpiredError": // 토큰이 기간만료 되었을 때 처리
            //         res.status(401).json({
            //             statusCode : 401,
            //             message: "TokenExpiredError",
            //         })
            //         break;
            //     case "JsonWebTokenError": // 에러 : 유효하지 않은 토큰일 때의 처리
            //         res.status(401).json({
            //             statusCode : 401,
            //             message: "JsonWebTokenError",
            //         })
            //         break;
            //     case "isEmpty refreshToken": // 에러 : 유효하지 않은 토큰일 때의 처리
            //         res.status(401).json({
            //             statusCode : 401,
            //             message: "isEmpty refreshToken",
            //         })
            //         break;
            //     default :
            //         // 3. getPresignedUrl 요청
            //         // await getPresignedUrl(userInfo);
            //         //console.log(`userInfo: `,userInfo)
            //
            //
            //         // 4. 글 등록
            //         // await boardService.boardCreate(userInfo);
            //
            //
            //         // 5. 클라이언트 전달 - 새로 발급한 access token과 원래 있던 refresh token 모두 클라이언트에게 반환합니다.
            //         res.status(200).json({
            //             statusCode : 200,
            //             "uploadUrl": userInfo.get("uploadUrl"),
            //         })
            // }

            // 3. getPresignedUrl 요청
            await getPresignedUrl(userInfo);
            console.log(`userInfo: `,userInfo)


            // 4. 글 등록
            await boardService.boardCreate(userInfo);


            // 5. 클라이언트 전달 - 새로 발급한 access token과 원래 있던 refresh token 모두 클라이언트에게 반환합니다.
            res.status(200).json({
                statusCode : 200,
                "uploadUrl": userInfo.get("uploadUrl"),
            })

            // https://velog.io/@kshired/Express%EC%97%90%EC%84%9C-JWT%EB%A1%9C-%EC%9D%B8%EC%A6%9D%EC%8B%9C%EC%8A%A4%ED%85%9C-%EA%B5%AC%ED%98%84%ED%95%98%EA%B8%B0-Access-Token%EA%B3%BC-Refresh-Token
            // access token과 refresh token의 존재 유무를 체크합니다.
        } else {
            res.status(401).json({
                statusCode : 401,
                error: 'Auth Error from authorization'
            });
        }
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


// 이미지 업로드용 pre-signed url 생성 - 참고: https://github.com/GursheeshSingh/flutter-aws-s3-upload/blob/master/server.js
const getPresignedUrl = async (userInfo) => {
    try {
        let image_url = userInfo.get("image_url");
        const word = image_url.split('.');
        const fileType = word[word.length-1];
        // console.log("fileType: " + fileType);

        if (fileType != "jpg" && fileType != "png" && fileType != "jpeg") {
            return "Image format invalid";
        }

        const fileName = uuid.v4();
        const s3Params = {
            Bucket: S3_BUCKET,
            Key: fileName + "." + fileType,
            Expires: 60 * 60,
            ContentType: "image/" + fileType,
            ACL: "public-read",
        };

        s3.getSignedUrl("putObject", s3Params, (err, url) => {
            if (err) {
                console.error("err: ",err);

                return res.status(500).json({
                    statusCode : 500,
                    error: err.message
                });
            }

            userInfo.set("uploadUrl", url);
            userInfo.set("downloadUrl", `https://usedmoa.s3.amazonaws.com/image/${fileName}` + "." + fileType);

            return userInfo;
        });
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


module.exports = {
    boardList,
    boardCreate,
    getPresignedUrl,
}