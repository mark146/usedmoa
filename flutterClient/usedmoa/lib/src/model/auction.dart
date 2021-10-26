class Auction {
  final String index;
  final String uri;
  final String auctionStatus;
  final String highestBidder;
  final String highestBiddingPrice;
  final String auctionEndTime;


  Auction({this.index, this.uri, this.auctionStatus, this.highestBidder, this.highestBiddingPrice, this.auctionEndTime});


  factory Auction.fromJson(Map<String, dynamic> json) {

    // 경매 진행 상황 설정
    String status = json['auctionStatus'] as String;
    switch(int.parse(status)){
      case 1:
        status = "종료";
        break;
      default :
        status = "진행중";
        break;
    }

    String endTime = "2021-10-21 19:47:00";
    print("endTime: ${endTime}");

    return Auction(
      index: json['index'] as String,
      uri: json['uri'] as String,
      auctionStatus: status,
      highestBidder: json['highestBidder'] as String,
      highestBiddingPrice: json['highestBiddingPrice'] as String,
      auctionEndTime: endTime,
    );
  }
}