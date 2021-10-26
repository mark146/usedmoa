class AuctionInfo {

    constructor(
        creator, productName, description, imageUri, auctionStatus,
        highestBidder, highestBiddingPrice, auctionEndTime
    ) {
        this.creator = creator; // 경매 생성자
        this.productName = productName; // 상품명
        this.description = description; // 상품 설명
        this.imageUri = imageUri; // 상품 이미지 정보
        this.auctionStatus = auctionStatus; // 경매 진행상황
        this.highestBidder = highestBidder; // 최고 입찰자
        this.highestBiddingPrice = highestBiddingPrice; // 최고 입찰가
        this.auctionEndTime = auctionEndTime; // 경매 종료 시간
    }
}

module.exports = AuctionInfo