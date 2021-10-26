import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:usedmoa/example/route_example.dart';
import 'package:usedmoa/src/ui/userInfo/login_screen.dart';
import 'package:usedmoa/src/ui/userInfo/video_call_list_screen.dart';
import 'ui/bottom_navigation.dart';
import 'ui/home/home_screen.dart';


// 멀티 페이지 라우트 설정 - 참고: https://jvvp.tistory.com/1123?category=883851
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버거 모드 표시 제거
      home: BottomNavigation(title: '중고거래'),
      initialRoute: '/',
      routes: {
        '/second': (context) => SecondRoute(),
        '/login': (context) => Login(),
        '/main' : (context) => Home(),
        '/video_call_list' : (context) => VideoCallListScreen(),
      },
    );
  }
}