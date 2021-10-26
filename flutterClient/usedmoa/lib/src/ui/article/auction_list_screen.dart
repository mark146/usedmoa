import 'dart:convert';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usedmoa/src/model/auction.dart';
import 'package:usedmoa/src/ui/article/auction_detail_screen.dart';
import 'item_detail_screen.dart';


class AuctionList extends StatefulWidget {
  @override
  _AuctionListState createState() => _AuctionListState();
}


// 참고:
// https://eunjin3786.tistory.com/249
// https://all-dev-kang.tistory.com/entry/%ED%94%8C%EB%9F%AC%ED%84%B0-%ED%8E%98%EC%9D%B4%EC%A7%80%EC%8A%A4%ED%81%AC%EB%A6%B0-%EA%B0%84%EC%9D%98-%EB%8D%B0%EC%9D%B4%ED%84%B0-%EC%A0%84%EC%86%A1
class _AuctionListState extends State<AuctionList> {
  List<Auction> auctionList = [];
  SharedPreferences prefs;


  @override
  void initState() {
    super.initState();

    auctionListRequest();
  }


  @override
  Widget build(BuildContext context) {
    var _listView = ListView.separated(
      padding: const EdgeInsets.all(3),
      itemCount: auctionList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
            onTap: () {
              // 상품 상세보기 페이지 이동
              print("경매 상품 상세보기 페이지 이동 -  auctionList[index]: ${auctionList[index]}");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AuctionDetail(auctionList[index]))
              );
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // 가로축 정렬 속성
                  children: <Widget>[
                    Expanded(
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
                              height: 150,
                              width: 100,
                              color: Colors.black12,
                              child: CachedNetworkImage(
                                imageUrl: auctionList[index].uri,
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
                      flex: 2,
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.only(left: 10, top: 15, right: 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Text("[${auctionList[index].auctionStatus}] test",
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.5)),

                              SizedBox(height: 30.0),

                              Text("${auctionList[index].highestBiddingPrice}원 ~",
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.5)),

                              SizedBox(height: 15.0),

                              Text("종료일"),

                              SizedBox(height: 5.0),

                              Row(children: [
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(auctionList[index].auctionEndTime,
                                        textAlign: TextAlign.start),
                                  ),
                                ),
                              ]),
                            ]
                        ),
                      ),
                    ),
                  ]
              ),
            )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );

    return CupertinoPageScaffold(
      child: _listView,
    );
  }


  // 글 목록 조회 - https://github.com/flutterchina/dio
  Future<Response<dynamic>> auctionListRequest() async {
    var dio = Dio();
    prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";

    final response = await dio.get(
      'https://www.usedmoa.co.kr/auction/list',
      options: Options(
        headers: {"authorization": "Bearer $accessToken"},
      ),
    );

    // print("서버 요청 결과 - auction/list: ${response}");
    // print("서버 요청 결과 - data.length: ${response.data["auctionList"].length}");


    setState(() {
      for(int i= 0; i<response.data["auctionList"].length; i++) {
        auctionList.add(Auction.fromJson(response.data["auctionList"][i]));
        // print("auctionList: "+response.data["auctionList"][i]["index"]);
      }
    });

    return response;
  }
}