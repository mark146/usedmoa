class AuctionListInfo {
    
    constructor(
        index, creator, uri, auctionStatus, highestBidder, highestBiddingPrice, auctionEndTime
    ) {
        this.index = index; // 경매 고유 ID 정보
        this.creator = creator; // 경매 생성자
        this.uri = uri; // 경매 이미지 URI 정보
        this.auctionStatus = auctionStatus; // 경매 상태값
        this.highestBidder = highestBidder; // 최고 입찰자
        this.highestBiddingPrice = highestBiddingPrice; // 최고 입찰가
        this.auctionEndTime = auctionEndTime; // 경매 종료 시간
    }
}

module.exports = AuctionListInfo