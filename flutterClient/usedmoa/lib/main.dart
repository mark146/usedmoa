import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 앱 시작점
Future main() async {

  // env 파일 초기화 -  참고 : https://github.com/java-james/flutter_dotenv
  await dotenv.load(fileName: ".env");

  // Kakao SDK 초기화
  KakaoContext.clientId = dotenv.env['KAKAO_APP_ID'];
  KakaoContext.javascriptClientId = dotenv.env['KAKAO_JavaScript_ID'];

  runApp(App()); // 1
}