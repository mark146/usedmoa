import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:kakao_flutter_sdk/common.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}


// 참고
// https://pub.dev/packages/kakao_flutter_sdk
// https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api
// https://developers.kakao.com/docs/latest/ko/kakaologin/android#sample-login
// https://github.com/flutterchina/dio
class _LoginState extends State<Login> {

  // 먼저 UI 요소에 적용할 사용자 정의 텍스트 스타일을 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  // 카카오로그인 실행
  Future<void> _loginButtonPressed() async {
    try {
      // 카카오톡의 설치 유무 확인
      final installed = await isKakaoTalkInstalled();
      print('kakao Install : ' + installed.toString());

      // 인증 코드 받기
      String authCode = await AuthCodeClient.instance.request();
      print("Kakao_Login_authCode: ${authCode}");

      // 획득한 인증 코드로 사용자에 대한 액세스 토큰을 발급
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      print("Kakao_Login_accessToken: ${token.accessToken}");
      print("Kakao_Login_refreshToken: ${token.refreshToken}");

      // 유저 정보 조회
      User user = await UserApi.instance.me();
      print("Kakao - nickname: ${user.kakaoAccount?.profile?.nickname}");
      print("Kakao - profileImageUrl: ${user.kakaoAccount?.profile?.profileImageUrl}");
      print("Kakao - email: ${user.kakaoAccount?.email}");


      // 서버 엑세스 토큰 요청
      var response = await loginRequest(token.accessToken);
      print("response: ${response}");

      // 성공할 경우에만 저장
      if(response.statusCode == 200) {

        // shared preferences 호출 후 값 저장
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_id', "${response.data['user_id'] ?? ""}");
        prefs.setString('nickname', user.kakaoAccount?.profile?.nickname ?? "");
        prefs.setString('email', response.data['email'] ?? "");
        prefs.setString('profileImageUrl', user.kakaoAccount?.profile?.profileImageUrl ?? "");
        prefs.setString('accessToken', response.headers.value("accesstoken") ?? "");
        prefs.setString('refreshToken', response.headers.value("refreshtoken") ?? "");

        print("accessToken: ${response.headers.value("accesstoken") ?? ""}");
        print("refreshToken: ${response.headers.value("refreshtoken") ?? ""}");

        // 뷰 종료 - 참고: https://origogi.github.io/flutter/flutter-push-pop-push/
        // Navigator.of(context).pop(context);
        Navigator.pop(context, true);
      } else {
        // 에러 처리
      }
    } catch (e) {
      print('error on login: $e');
    }
  }


  // 서버 엑세스 토큰 요청
  Future<Response<dynamic>> loginRequest(accessToken) async {
    Response<dynamic> response;
    try {
      var dio = Dio();
      response = await dio.post(
          'https://www.usedmoa.co.kr/users/login',
          options: Options(
            headers: {"authorization": "Bearer $accessToken"},
          ));
      // print("서버 요청 결과 - headers: ${response}");
      // print("서버 요청 결과 - statusCode: ${response.statusCode}");
      // print("서버 요청 결과 - headers(accesstoken): ${response.headers.value("accesstoken")}");
      // print("서버 요청 결과 - headers(refreshtoken): ${response.headers.value("refreshtoken")}");
      // print("서버 요청 결과 - data: ${response.data}");

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


  // 클래스 본문 내에서 build기본 위젯을 반환 하는 함수 를 재정의해야 합니다 .
  @override
  Widget build(BuildContext context) {

    // 카카오 로그인 버튼 UI
    final kakaoLoginButon = Material(
      elevation: 5.0, // 버튼에 그림자 추가
      borderRadius: BorderRadius.circular(30.0), // 테두리 둥글게 설정
      color: Colors.amberAccent,
      child: MaterialButton( // 위젯을 자식으로 사용하는 재료 위젯을 자식으로 추가
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          print("카카오 로그인 실행");
          _loginButtonPressed();
        }, // 버튼에는 onPressed클릭할 때마다 호출되는 함수를 사용 하는 속성이 있습니다.
        child: Text("Kakao Login",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    // SizedBox는 간격을 두는 용도로만 위젯 을 사용
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black12, // 배경색 설정
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("중고모아",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 50, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 120.0),

                // 카카오 로그인 버튼 UI
                kakaoLoginButon,

                SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}