import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usedmoa/src/blockChain/EthereumModel.dart';
import 'package:usedmoa/src/model/auction.dart';


class AuctionDetail extends StatefulWidget {

  Auction auctionInfo;

  // 기본 생성자: 변수 선언 후 초기화 및 입력 - 참고: https://brunch.co.kr/@mystoryg/123
  AuctionDetail(this.auctionInfo) {
    auctionInfo = auctionInfo;
  }

  @override
  _AuctionDetailState createState() => _AuctionDetailState(auctionInfo);
}


class _AuctionDetailState extends State<AuctionDetail> {

  // 텍스트 스타일 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 17.0);
  TextStyle titleStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 17.0);
  TextStyle contentStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);

  StreamController<String> streamController = StreamController<String>();
  Auction auctionInfo;
  BuildContext detailContext;
  var money;


  String creator = "";
  String productName = "";
  String description = "";
  String imageUri = "";
  String auctionStatus = "";
  String highestBidder = "";
  String highestBiddingPrice = "";
  String auctionEndTime = "";

  // 최소 입찰가 UI
  final bidController = TextEditingController();
  final userTokenController = TextEditingController();


  _AuctionDetailState(Auction auctionInfo) {
    this.auctionInfo = auctionInfo;
  }


  //  딱 1번만 실행되고 절대 다시는 실행되지 않습니다
  @override
  void initState() {
    super.initState();
    print("initState 실행");

    getTokenInfoRequest();

    // 경매 정보 조회
    auctionDetailRequest(auctionInfo).then((value) => {
      setState(() {
        streamController.add("");
      })
    });


    // 이더리움 클래스 생성
    // var ethereum = Ethereum();

    // 이더리움 지갑 연결 테스트
    // var result = ethereum.getBalance();
    // result.then((value) => {
    //   money = value,
    //   streamController.add(value.toString())
    // });
  }


  // 참고: https://here4you.tistory.com/111
  @override
  Widget build(BuildContext context) {
    this.detailContext = context;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('경매 상품 상세보기', textAlign: TextAlign.start),
      ),
      body: mainScrollView(),
    );
  }

  // 메인 스크롤뷰 UI
  Widget mainScrollView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      //  scrollDirection 속성을 사용해 원하는 스크롤 방향을 지정할 수 있습니다.
      padding: const EdgeInsets.all(5),
      child: StreamBuilder(
        stream: streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("snapshot.data: ${snapshot.data}");
            print("auctionStatus: ${auctionStatus}");

            if(auctionStatus == "종료") {
              return endAictionView();
            } else {
              return detailView();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }


  Widget detailView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // 사진 UI
        Container(
          padding: const EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black12,
                    width: 1.0
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(10) // POINT
                ),
              ),
              child: ClipRRect(
                  child: Container(
                    height: (MediaQuery.of(context).size.height/4),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black12,
                    child:
                    CachedNetworkImage(
                      imageUrl: imageUri,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )
              ),
            ),
          ),
        ),

        // 경매 진행 상황, 종료시간 UI
        Container(
          padding: const EdgeInsets.only(top: 0, left: 5, right: 20, bottom: 10),
          alignment: Alignment.centerLeft,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
            children: [
              Text("[${auctionStatus}]",
                  maxLines: 1, textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 19.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),

              SizedBox(width: 15), //SizedBox

              Text("종료시간  ${auctionEndTime}",
                  maxLines: 1, textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),

        // 상품명 UI
        Container(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 10, bottom: 10),
          alignment: Alignment.centerLeft,
          child: Text(productName,
              maxLines: 1, textAlign: TextAlign.start,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),

        // 상품 내용 UI
        Container(
          width: 360,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12, width: 1.0),
          ),
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          child:Text(description,
              textAlign: TextAlign.start,
              style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),

        SizedBox(height: 10),

        // 상품글 제목 UI
        Container(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 5),
          child: Text("경매 상품 입찰 현황",
              maxLines: 1, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),


        // 최고 입찰자, 입찰가 UI
        Container(
          padding: const EdgeInsets.only(top: 5, left: 7, right: 7, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              // 최고 입찰자 UI
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12, width: 1.0),
                  ),
                  padding: const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("최고 입찰자",
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),

                      Text(highestBidder,
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ), //Container
              ), //Flexible

              SizedBox(width: 20), //SizedBox

              // 최고 입찰가 UI
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12, width: 1.0),
                  ),
                  padding: const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("최고 입찰가",
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),

                      Text("${highestBiddingPrice} 원",
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ), //Container
              ),
            ],
          ),
        ),
        SizedBox(height: 10),

        // 최소 입찰 UI
        Container(
          height: 70,
          padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 최소 입찰가 UI
              SizedBox(width: 10),
              Text("최소 입찰가",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 15),


              // 입찰 금액 UI
              Flexible(
                child: Container(
                  // margin: EdgeInsets.only(right: 10),
                  width: 160,
                  child: CupertinoTextField(
                    controller: bidController,
                    textAlign: TextAlign.center,
                    placeholder: "입찰 금액",
                    // enabled: false,
                    padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(color: Colors.green, width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text("원",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 10),


              // 입찰 하기 버튼 UI
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width/8,
                padding: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Text("입찰 하기",
                    textAlign: TextAlign.center,
                    style: titleStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                color: Colors.green,
                onPressed: () {
                  print("입찰 이벤트 실행");


                  auctionBidRequest(auctionInfo);
                  //bidDialog();
                },
              ),
              SizedBox(width: 5),
            ],
          ),
        ),
        SizedBox(height: 5),


        // 소지 금액 UI
        Container(
          height: 60,
          padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("소지 금액",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 20),

              Flexible(
                child: Container(
                  width: 160,
                  // 참고 : https://api.flutter.dev/flutter/cupertino/CupertinoSearchTextField-class.html
                  child: CupertinoTextField(
                    controller: userTokenController,
                    textAlign: TextAlign.center,
                    placeholder: "소지 금액",
                    enabled: false,
                    padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(color: Colors.green, width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text("원",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 13),
            ],
          ),
        ),
      ],
    );
  }

  Widget endAictionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // 사진 UI
        Container(
          padding: const EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black12,
                    width: 1.0
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(10) // POINT
                ),
              ),
              child: ClipRRect(
                  child: Container(
                    height: (MediaQuery.of(context).size.height/4),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black12,
                    child:
                    CachedNetworkImage(
                      imageUrl: imageUri,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )
              ),
            ),
          ),
        ),

        // 경매 진행 상황, 종료시간 UI
        Container(
          padding: const EdgeInsets.only(top: 0, left: 5, right: 20, bottom: 10),
          alignment: Alignment.centerLeft,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
            children: [
              Text("[${auctionStatus}]",
                  maxLines: 1, textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 19.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),

              SizedBox(width: 15), //SizedBox

              Text("종료시간  ${auctionEndTime}",
                  maxLines: 1, textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),

        // 상품명 UI
        Container(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 10, bottom: 10),
          alignment: Alignment.centerLeft,
          child: Text(productName,
              maxLines: 1, textAlign: TextAlign.start,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),

        // 상품 내용 UI
        Container(
          width: 360,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12, width: 1.0),
          ),
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          child:Text(description,
              textAlign: TextAlign.start,
              style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),

        SizedBox(height: 10),

        // 상품글 제목 UI
        Container(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 5),
          child: Text("경매 상품 입찰 현황",
              maxLines: 1, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),


        // 최고 입찰자, 입찰가 UI
        Container(
          padding: const EdgeInsets.only(top: 5, left: 7, right: 7, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              // 최고 입찰자 UI
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12, width: 1.0),
                  ),
                  padding: const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("최고 입찰자",
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),

                      Text(highestBidder,
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ), //Container
              ), //Flexible

              SizedBox(width: 20), //SizedBox

              // 최고 입찰가 UI
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12, width: 1.0),
                  ),
                  padding: const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("최고 입찰가",
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),

                      Text("${highestBiddingPrice} 원",
                          textAlign: TextAlign.start,
                          style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ), //Container
              ),
            ],
          ),
        ),
        SizedBox(height: 10),

        // 소지 금액 UI
        Container(
          height: 60,
          padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("소지 금액",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 20),

              Flexible(
                child: Container(
                  width: 160,
                  // 참고 : https://api.flutter.dev/flutter/cupertino/CupertinoSearchTextField-class.html
                  child: CupertinoTextField(
                    controller: userTokenController,
                    textAlign: TextAlign.center,
                    placeholder: "소지 금액",
                    enabled: false,
                    padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(color: Colors.green, width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text("원",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 17.0).copyWith(color: Colors.black, fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 13),
            ],
          ),
        ),
      ],
    );
  }


  // 입찰 이벤트 실행 함수
  void bidDialog() {
    showDialog(
        context: context,
        barrierDismissible: false, //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Column(
              children: <Widget>[
                new Text("입찰"),
              ],
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                // 결제방법 UI
                Container(
                  padding: const EdgeInsets.only(
                      top: 5, left: 0, right: 0, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        //fit: BoxFit.scaleDown,
                        child: Text("최고 입찰가",
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontStyle: FontStyle.normal)
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 5),

                // 결제방법 UI
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start, // 가로축 정렬 속성
                    //  Container 배치순서를 바꾸지 않고 간격을 바꾸고 싶을때 사용
                    children: <Widget>[
                      Text("10000원",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              letterSpacing: 0.5)
                      ),
                    ]
                ),

                SizedBox(height: 5),
                Divider(),
                SizedBox(height: 5),

                // 결제금액 UI
                Container(
                  padding: const EdgeInsets.only(
                      top: 5, left: 0, right: 0, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        //fit: BoxFit.scaleDown,
                        child: Text("결제금액",
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                // 결제금액 UI
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // 가로축 정렬 속성
                    //  Container 배치순서를 바꾸지 않고 간격을 바꾸고 싶을때 사용
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("결제금액",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.5)
                              ),
                            ]
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text("2000 원", textAlign: TextAlign.center),
                        ),
                      ),
                    ]
                ),

                SizedBox(height: 10),

                Divider(),

                SizedBox(height: 5),

                // 총 결제금액 UI
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // 가로축 정렬 속성
                    //  Container 배치순서를 바꾸지 않고 간격을 바꾸고 싶을때 사용
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("총 결제금액",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.5)
                              ),
                            ]
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text("2000 원", textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]
                ),

                SizedBox(height: 10),

              ],
            ),

            actions: <Widget>[
              new FlatButton(
                child: new Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              new FlatButton(
                child: new Text("결제하기"),
                onPressed: () {
                  Navigator.pop(context);
                  _showDialog();
                },
              ),
            ],
          );
        });
  }


  // 참고: https://dalgonakit.tistory.com/109
  void _showDialog() {
    showDialog(
      context: detailContext,
      builder: (BuildContext context) {
        // 이더리움 클래스 생성
        var ethereum = Ethereum();
        ethereum.sendTokens(2000);

        Future.delayed(Duration(seconds: 3), () {
          Navigator.pop(context);

          final snackBar = SnackBar(content: Text('결제 완료!'));
          ScaffoldMessenger.of(detailContext).showSnackBar(snackBar);
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
          ),
          content: SizedBox(
            height: 200,
            child: Center(
                child: SizedBox(
                  child: new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation(Colors.blue),
                      strokeWidth: 5.0
                  ),
                  height: 50.0,
                  width: 50.0,
                )
            ),
          ),
        );
      },
    );
  }



  // 경매 정보 조회 - https://github.com/flutterchina/dio
  Future<Response<dynamic>> auctionDetailRequest(Auction auctionInfo) async {
    print("auctionInfo.index: ${auctionInfo.index}");

    var dio = Dio();
    final response = await dio.get(
        'https://www.usedmoa.co.kr/auction/detail',
        queryParameters: {'id': auctionInfo.index}
    );

    // print("서버 요청 결과 - data: ${response.data["auctionInfo"]}");
    // print("data[auctionInfo][creator]: ${response.data["auctionInfo"]["creator"]}");
    // print("data[auctionInfo][productName]: ${response.data["auctionInfo"]["productName"]}");
    // print("data[auctionInfo][description]: ${response.data["auctionInfo"]["description"]}");
    // print("data[auctionInfo][imageUri]: ${response.data["auctionInfo"]["imageUri"]}");
    // print("data[auctionInfo][auctionStatus]: ${response.data["auctionInfo"]["auctionStatus"]}");
    // print("data[auctionInfo][highestBidder]: ${response.data["auctionInfo"]["highestBidder"]}");
    // print("data[auctionInfo][highestBiddingPrice]: ${response.data["auctionInfo"]["highestBiddingPrice"]}");
    // print("data[auctionInfo][auctionEndTime]: ${response.data["auctionInfo"]["auctionEndTime"]}");

    creator = response.data["auctionInfo"]["creator"];
    productName = response.data["auctionInfo"]["productName"];
    description = response.data["auctionInfo"]["description"];
    imageUri = response.data["auctionInfo"]["imageUri"];
    //auctionStatus = response.data["auctionInfo"]["auctionStatus"];


    highestBidder = response.data["auctionInfo"]["highestBidder"];
    highestBiddingPrice = response.data["auctionInfo"]["highestBiddingPrice"];

    // auctionEndTime = response.data["auctionInfo"]["auctionEndTime"];

    String endTime = "2021-10-21 19:47:00";
    print("endTime: ${endTime}");
    auctionEndTime = endTime;

    // 최소 입찰가 Text 값 입력
    bidController.text = highestBiddingPrice;


    // 경매 진행 상황 설정
    switch(int.parse(response.data["auctionInfo"]["auctionStatus"])){
      case 1:
        auctionStatus = "종료";
        break;
      default :
        auctionStatus = "진행중";
        break;
    }


    return response;
  }


  // 경매 입찰 요청
  Future<Response<dynamic>> auctionBidRequest(Auction auctionInfo) async {
    var dio = Dio();
    final response = await dio.post(
        'https://www.usedmoa.co.kr/auction/bid',
        data: {
          'auctionId': auctionInfo.index,
          'userId': "master",
          'bidPrice': bidController.text
        }
    );

    setState(() {
      highestBiddingPrice =  bidController.text;
    });


    return response;
  }


  // 토큰 정보 조회
  Future<Response<dynamic>> getTokenInfoRequest() async {
    var dio = Dio();
    final response = await dio.get(
        'https://www.usedmoa.co.kr/users/tokenAmount',
        queryParameters: {'userId': "master"}
    );
    userTokenController.text = response.data["amount"];
    return response;
  }
}