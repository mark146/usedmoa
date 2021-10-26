import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usedmoa/src/model/videoCall.dart';
import 'package:usedmoa/src/ui/userInfo/video_player_screen.dart';



class VideoCallListScreen extends StatefulWidget {

  @override
  _VideoCallListScreenState createState() => _VideoCallListScreenState();
}


class _VideoCallListScreenState extends State<VideoCallListScreen> {
  List<VideoCall> VideoCallList = [];
  SharedPreferences prefs;


  // 딱 1번만 실행되고 절대 다시는 실행되지 않습니다
  @override
  void initState() {
    super.initState();
    print("_VideoCallListScreenState - initState 실행");

    // 사용자 정보 조회
    _userInfo();

    // 영상 목록 조회
    vodListRequest();
  }


  // 사용자 정보 조회
  _userInfo() async {
    prefs = await SharedPreferences.getInstance();
  }


// 글 목록 조회
// https://github.com/flutterchina/dio
  Future<Response<dynamic>> vodListRequest() async {
    var dio = Dio();
    prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";
    String user_id = prefs.getString("user_id") ?? "";

    final response = await dio.get(
      'https://www.usedmoa.co.kr/vod/list',
      options: Options(
        headers: {"authorization": "Bearer $accessToken"},
      ),
        queryParameters: {'user_id': user_id}
    );
    print("서버 요청 결과 - data: ${response.data["list"]}");

    setState(() {
      for(int i= 0; i<response.data["list"].length; i++) {
        VideoCallList.add(VideoCall.fromJson(response.data["list"][i]));
      }
    });

    return response;
  }



  @override
  Widget build(BuildContext context) {

    var _listView = ListView.separated(
      padding: const EdgeInsets.all(3),
      itemCount: VideoCallList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
            onTap: () {
              // 상품 상세보기 페이지 이동
              print("영상 보기 이동 -  boardList[index]: ${VideoCallList[index].video_url}");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VideoPlayerScreen(VideoCallList[index]))
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
                              child:
                              Container(
                                height: 150,
                                width: 100,
                                color: Colors.black12,
                                child: Image.network(
                                  VideoCallList[index].image_url, // 해당 url 값을 이미지로
                                  fit: BoxFit.fitHeight, // 이미지 채우기
                                  width: double.infinity,
                                  height: 150,
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
                                Text(VideoCallList[index].title,
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
                                          child: Text(VideoCallList[index].create_date,
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


    return Scaffold(
      appBar: AppBar(
        title: const Text('영상통화 목록'),
      ),
      body: Builder(builder: (BuildContext context) {
        return CupertinoPageScaffold(
          child: _listView,
        );
      }),
    );

  }
}


