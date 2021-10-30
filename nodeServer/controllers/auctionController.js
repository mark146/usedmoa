const dotenv = require('dotenv').config();
const {auctionService} = require('../services')


// 경매 목록
const auctionList = async (req, res, next) => {
    try {
        //console.log("auctionList - req: ",req)
        // let accessToken = "";
        // let userInfo = new Map();
        // userInfo.set("user_id", req.body.user_id);
        // userInfo.set("image_url", req.body.imageUrl);
        // userInfo.set("product_name", req.body.product_name);
        // userInfo.set("product_price", req.body.product_price);
        // userInfo.set("content", req.body.content);
        // userInfo.set("auction_start_time", req.body.auction_start_time);
        // userInfo.set("auction_end_time", req.body.auction_end_time);

        const result = await auctionService.auctionList();
        // console.info("result: ",result);


        // 결과값 전송
        res.status(200).json({
            statusCode : 200,
            auctionList: result,
        })
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


// 경매 생성
// https://docs.ethers.io/v5/api/signer/#Wallet-createRandom
// https://ethereum.stackexchange.com/questions/95218/how-can-i-transfer-tokens-of-my-erc20-automatically-from-the-server/95221
const auctionCreate = async (req, res, next) => {
    try {
        let accessToken = "";
        let userInfo = new Map();
        userInfo.set("user_id", req.body.user_id);
        userInfo.set("image_url", req.body.image_url);
        userInfo.set("product_name", req.body.product_name);
        userInfo.set("product_price", req.body.product_price);
        userInfo.set("content", req.body.content);
        userInfo.set("auction_start_time", req.body.auction_start_time);
        userInfo.set("auction_end_time", req.body.auction_end_time);
        console.log("auctionCreate - userInfo: ",userInfo)


        // 비즈니스 로직 처리
        await auctionService.auctionCreate(userInfo);


        // 결과값 전송
        res.status(200).json({
            statusCode : 200,
            user_id : userInfo.get("user_id"),
            image_url : userInfo.get("image_url"),
            product_name : userInfo.get("product_name"),
            product_price : userInfo.get("product_price"),
            content : userInfo.get("content"),
            auction_start_time : userInfo.get("auction_start_time"),
            auction_end_time : userInfo.get("auction_end_time")
        })
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


// 경매 정보 조회 - 경매 종료 시간, 상품명, 상품 내용, 최고 입찰자, 최고 입찰가
const auctionDetail = async (req, res, next) => {
    try {
        console.log("auctionDetail - req: ",req.query.id)


        // 비즈니스 로직 처리
        // await AuctionService.auctionDetail(req.query.id);
        const result = await auctionService.auctionDetail(req.query.id);
        console.log("auctionDetail - result: ",result)


        // 결과값 전송
        res.status(200).json({
            statusCode : 200,
            auctionInfo : result
        })
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


// 경매 입찰
const auctionBid = async (req, res, next) => {
    try {
        let userInfo = new Map();
        // console.log("auctionBid - req.body: ", req.body)
        // console.log("auctionBid - req.body.auctionId: ", req.body.auctionId)
        // console.log("auctionBid - req.body.userId: ", req.body.userId)
        // console.log("auctionBid - req.body.bidPrice: ", req.body.bidPrice)


        switch (req.body.userId) {
            case "master":
                userInfo.set("userAddress", process.env.TOKEN_MASTER_ADDRESS);
                break
            case "user_v1":
                userInfo.set("userAddress", process.env.USER_V1_ADDRESS);
                break
            case "user_v2":
                userInfo.set("userAddress", process.env.USER_V2_ADDRESS);
                break
            default:
                console.log("default: ",req.query.userId);
        }


        const result = await auctionService.auctionBid(req.body.auctionId, userInfo.get("userAddress"), req.body.bidPrice);
        console.info("result: ",result);


        // 결과값 전송
        res.status(200).json({
            statusCode : 200,
            result: result
        })
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


// 경매 종료
const auctionEnd = async (req, res, next) => {
    try {
        console.log("auctionEnd - req: ",req.body)
        // let accessToken = "";
        // let userInfo = new Map();
        // userInfo.set("user_id", req.body.user_id);
        // userInfo.set("image_url", req.body.imageUrl);


        const result = await auctionService.auctionEnd(req.body.auctionId);
        console.info("result: ",result);


        // 결과값 전송
        res.status(200).json({
            statusCode : 200,
            message: result,
        })
    } catch (err) {
        console.error("err: ",err);

        res.status(500).json({
            statusCode : 500,
            error: err.message
        });
    }
}


module.exports = {
    auctionList,
    auctionCreate,
    auctionDetail,
    auctionBid,
    auctionEnd,
}