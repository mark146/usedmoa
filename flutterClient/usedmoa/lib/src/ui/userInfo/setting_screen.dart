import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';


class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}


class _SettingState extends State<Setting> {
  StreamController<String> ethereumController = StreamController<String>();
  StreamController<String> loginController = StreamController<String>();

  // 먼저 UI 요소에 적용할 사용자 정의 텍스트 스타일을 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 17.0);
  TextStyle nameStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 15.0);


  // shared preferences 얻기
  SharedPreferences prefs;
  String nickname = "";
  String email = "";
  String profileImageUrl = "";
  String balance = "balance";
  String user_id = "";
  String blance = "0";


  // 딱 1번만 실행되고 절대 다시는 실행되지 않습니다
  @override
  void initState() {
    super.initState();
    print("initState 실행");

    _loadInfo();
  }


  // 로그인 정보 조회
  _loadInfo() async {
    // SharedPreferences의 인스턴스를 필드에 저장
    prefs = await SharedPreferences.getInstance();
    nickname = prefs.getString("nickname") ?? "";
    email = prefs.getString("email") ?? "";
    profileImageUrl = prefs.getString("profileImageUrl") ?? "";
    user_id = prefs.getString("user_id") ?? "";

    print("_loadInfo - nickname: ${nickname}");
    print("_loadInfo - profileImageUrl: ${profileImageUrl}");
    print("_loadInfo - email: ${email}");
    print("_loadInfo - user_id: ${user_id}");

    loginController.add(nickname);
  }


  // 로그인하기 버튼 누를 경우 실행
  _login() async {
    print("_login 실행");

    prefs = await SharedPreferences.getInstance();
    nickname = prefs.getString("nickname") ?? "";
    email = prefs.getString("email") ?? "";
    profileImageUrl = prefs.getString("profileImageUrl") ?? "";
    print("_login - nickname: ${nickname}");
    print("_login - profileImageUrl: ${profileImageUrl}");
    print("_login - email: ${email}");

    loginController.add(nickname);
  }


  // 로그아웃
  _logout() async {
    // SharedPreferences의 인스턴스를 필드에 저장
    prefs = await SharedPreferences.getInstance();
    prefs.setString('nickname', "");
    prefs.setString('email', "");
    prefs.setString('profileImageUrl', "");
    nickname = "";
    email = "";
    profileImageUrl = "";
    loginController.add(nickname);
  }


  // 클래스 본문 내에서 build기본 위젯을 반환 하는 함수 를 재정의해야 합니다 .
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainScrollView(),
    );
  }


  // 메인 스크롤뷰 UI
  Widget mainScrollView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(5), // 사용해 원하는 스크롤 방향을 지정
      child: StreamBuilder(
        stream: loginController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("snapshot.data: ${snapshot.data}");
            String result = snapshot.data.toString();
            // 비로그인일 경우
            if (result == "") {
              return defaultLoginView();
            } else {
              // 로그인 할 경우
              return loginView();
            }
          } else {
            // 비로그인일 경우
            return defaultLoginView();
          }
        },
      ),
    );
  }


  // 로그인 했을 경우
  Widget loginView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // 유저 정보 UI
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundImage: AssetImage('assets/images/mountain.jpg'),
          ),
          accountEmail: Text(email,
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.black, fontWeight: FontWeight.w500)),
          accountName: Text(nickname,
              textAlign: TextAlign.center,
              style: nameStyle.copyWith(
                  color: Colors.black, fontWeight: FontWeight.w500)),
          decoration: BoxDecoration(
            color: Colors.white70,
          ),
        ),

        SizedBox(height: 20),

        // 전자지갑 UI
        Container(
          padding: EdgeInsets.all(5),
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.card_membership),
                    SizedBox(width: 5),
                    Text("보유금액", textAlign: TextAlign.center,
                        style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FutureBuilder(
                        future: getTokenInfoRequest(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          //해당 부분은 data를 아직 받아 오지 못했을때 실행되는 부분을 의미한다.
                          if (snapshot.hasData == false) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {  //error가 발생하게 될 경우 반환하게 되는 부분
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(fontSize: 8),
                              ),
                            );
                          } else {  // 데이터를 정상적으로 받아오게 될 경우 실행

                            try {
                              print("snapshot.data.toString(): ${snapshot.data.toString()}");
                              print("snapshot.data.statusCode: ${snapshot.data.statusCode}");
                              switch(snapshot.data.statusCode) {
                                case 500 :
                                  print("case 500 : ${snapshot.data.toString()}");
                                  break;
                                case 401 :
                                  print("case 401 : ${snapshot.data.toString()}");
                                  // 엑세스, 리프래시 토큰 재요청
                                  refreshTokenRequest();

                                  // 토큰 갯수 정보 조회
                                  getTokenInfoRequest();
                                  break;
                                default :
                                  print("default : ${snapshot.data.toString()}");
                              }
                            } catch(error) {
                              print("error: ${error}");
                            }
                            print("결과값 UI 반영 : ${snapshot.data.toString()}");
                            // 결과값 UI 반영
                            return Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text(
                                snapshot.data+" 원",
                                textAlign: TextAlign.center,
                                style:  TextStyle(fontSize: 14),
                              ),
                            );
                          }
                        }),
                  ],
                ),
              ),
            ),
          ]),
        ),
        SizedBox(height: 20),

        // 거래내역 UI
        Container(
          padding: const EdgeInsets.all(5),
          child: Row(children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.list_alt),
                    SizedBox(width: 10),
                    Text("거래내역",
                        textAlign: TextAlign.center,
                        style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.navigate_next, color: Colors.grey),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ]),
        ),
        SizedBox(height: 20),

        // 영상 다시보기 UI
        GestureDetector(
          onTap: () {
            print("영상 다시보기 clicked");

            Navigator.pushNamed(context, '/video_call_list').then((value) {
              if (value == true) {
                setState(() {
                  print("setState");
                });
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Row(children: [
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.voice_chat_outlined),
                      SizedBox(width: 10),
                      Text("영상통화 다시보기",
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.navigate_next, color: Colors.grey),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
        SizedBox(height: 20),

        // 로그인 UI - 클릭 이벤트 참고: https://www.codegrepper.com/code-examples/dart/flutter+container+onclick
        GestureDetector(
          onTap: () {
            print("로그아웃 clicked");
            setState(() {
              _logout();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Row(children: [
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.offline_bolt_outlined),
                      SizedBox(width: 10),
                      Text("로그아웃",
                          textAlign: TextAlign.center,
                          style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }


  // 비로그인일 경우 설정 UI
  Widget defaultLoginView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),


        // 알림 설정 UI
        Container(
          padding: const EdgeInsets.all(5),
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    Text("알림 설정", textAlign: TextAlign.center, style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ]),
        ),
        SizedBox(height: 30),


        // 버전 UI
        Container(padding: const EdgeInsets.all(5),
          child: Row(children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    Text("버전 1.0.0", textAlign: TextAlign.center, style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ]),
        ),
        SizedBox(height: 30),


        // 로그인하러 가기 UI
        Material(
          elevation: 5.0, // 버튼에 그림자 추가
          borderRadius: BorderRadius.circular(30.0), // 테두리 둥글게 설정
          color: Color(0xff01A0C7),
          child: MaterialButton( // 위젯을 자식으로 사용하는 재료 위젯을 자식으로 추가
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              print("로그인 clicked");
              Navigator.pushNamed(context, '/login').then((value) {
                if (value == true) {
                  setState(() {
                    print("setState");
                    _login();
                  });
                }
              });
            },
            child: Text("로그인하러 가기", textAlign: TextAlign.center, style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }


  // 사용자 보유 토큰 정보 요청
  Future<Response<dynamic>> getTokenInfoRequest() async {
    final prefs = await SharedPreferences.getInstance();
    var walletAddress = prefs.getString("walletAddress") ?? "";
    var accessToken = prefs.getString("accessToken") ?? "";

    Response<dynamic> response;
    try {
      var dio = Dio();
      final response = await dio.get(
          'https://www.usedmoa.co.kr/users/balance',
          options: Options(
            headers: {"authorization": "Bearer $accessToken"},
          ),
          queryParameters: {'walletAddress': walletAddress}
      );


      prefs.setString('amount', response.data["amount"]);
      blance = response.data["amount"];
      ethereumController.add(blance);
      print("getTokenInfoRequest() - headers: ${response}");
    } on DioError catch (error) {
      if (error.response != null) {
        print("error.response.data: ${error.response.data}");
      } else {
        print("error.message: ${error.response}");
      }
      response = error.response;
    }

    return response;
  }


  // 엑세스 토큰 요청 - 참고 : https://github.com/flutterchina/dio#examples
  Future<Response<dynamic>> refreshTokenRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString("accessToken") ?? "";
    String refreshToken = prefs.getString("refreshToken") ?? "";

    Response<dynamic> response;
    try {
      List<Cookie> cookies = [
        new Cookie("refresh", refreshToken),
      ];
      var cookieJar=CookieJar();
      cookieJar.saveFromResponse(Uri.parse('https://www.usedmoa.co.kr/users/refresh'), cookies);


      var dio = Dio();
      dio.interceptors.add(CookieManager(cookieJar));
      response = await dio.post(
          'https://www.usedmoa.co.kr/users/refresh',
          options: Options(
              headers: {
                "authorization": "Bearer $accessToken",
              })
      );
      print("response: ${response}");

      if(response.statusCode == 200) {
        prefs.setString("accessToken", response.headers.value("accesstoken") ?? "");

        var refreshtoken = response.headers.value("refreshtoken") ?? "";
        if(refreshtoken != "") {
          prefs.setString("refreshToken", response.headers.value("refreshtoken") ?? "");
        }

        print("accessToken: ${response.headers.value("accesstoken") ?? ""}");
        print("refreshToken: ${response.headers.value("refreshtoken") ?? ""}");
      }
    } on DioError catch (error) {
      if (error.response != null) {
        print("error.response.data: ${error.response.data}");
      } else {
        print("error.message: ${error.response}");
      }
      response = error.response;
    }

    return response;
  }

}



// 토큰 정보 조회
// Future<String> getTokenInfoRequest() async {
//   // shared preferences 에 값 저장
//   final prefs = await SharedPreferences.getInstance();
//   var walletAddress = prefs.getString("walletAddress") ?? "";
//
//   var dio = Dio();
//   final response = await dio.get(
//       'https://www.usedmoa.co.kr/users/tokenAmount',
//       queryParameters: {'walletAddress': walletAddress}
//   );
//
//   prefs.setString('amount', response.data["amount"]);
//   return response.data["amount"];
// }
