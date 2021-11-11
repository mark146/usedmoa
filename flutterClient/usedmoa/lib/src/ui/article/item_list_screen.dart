import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usedmoa/src/model/board.dart';
import 'item_detail_screen.dart';


class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}


// 참고:
// https://eunjin3786.tistory.com/249
// https://all-dev-kang.tistory.com/entry/%ED%94%8C%EB%9F%AC%ED%84%B0-%ED%8E%98%EC%9D%B4%EC%A7%80%EC%8A%A4%ED%81%AC%EB%A6%B0-%EA%B0%84%EC%9D%98-%EB%8D%B0%EC%9D%B4%ED%84%B0-%EC%A0%84%EC%86%A1
class _ItemListState extends State<ItemList> {
  List<Board> boardList = [];
  SharedPreferences prefs;


  @override
  void initState() {
    super.initState();

    boardListRequest();
  }


  @override
  Widget build(BuildContext context) {
    var _listView = ListView.separated(
      padding: const EdgeInsets.all(3),
      itemCount: boardList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
            onTap: () {
              // 상품 상세보기 페이지 이동
              print("상품 상세보기 이동 -  boardList[index]: ${boardList[index]}");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ItemDetail(boardList[index]))
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
                              Radius.circular(15) // POINT
                          ),
                        ),
                        child: ClipRRect(
                            child:
                            Container(
                              height: 150,
                              width: 100,
                              color: Colors.black12,
                              child:
                              CachedNetworkImage(
                                imageUrl: boardList[index].image_url,
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
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
                              Text("[${boardList[index].status}] "+boardList[index].title,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.5)),

                              SizedBox(height: 75.0),

                              Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(boardList[index].create_date,
                                            textAlign: TextAlign.center),
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
  Future<Response<dynamic>> boardListRequest() async {
    var dio = Dio();
    prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";


    final response = await dio.get(
      'https://www.usedmoa.co.kr/board/list',
      options: Options(
        headers: {"authorization": "Bearer $accessToken"},
      ),
    );
    // print("서버 요청 결과 - data.length: ${response.data["list"].length}");
    // print("서버 요청 결과 - list: ${response.data["list"][0]}");
    // print("서버 요청 결과 - id: ${response.data["list"][0]["id"]}");
    // print("서버 요청 결과 - boardList.length: ${boardList.length}");

    setState(() {
      for(int i= 0; i<response.data["list"].length; i++) {
        boardList.add(Board.fromJson(response.data["list"][i]));
        //print("image_url: "+response.data["list"][i]["image_url"]);
      }
    });

    return response;
  }
}