import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
//import 'package:test_app/model/blockChain/EthereumModel.dart';

/*
// 참고: https://pub.dev/packages/http
// 참고 : https://flutter-ko.dev/docs/cookbook/networking/fetch-data
Future<UserInfo> fetchUserInfo() async {
  var url = Uri.parse('http://3.37.98.196:8080/board/json');

  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': "application/json",
      "Access-Control-Allow-Origin": "*"
    },
    body: jsonEncode(
      {
        'id': 'name',
        'pw': '1234',
      },
    ),
  );

  print("response.statusCode: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    // 만약 서버로의 요청이 성공하면, JSON을 파싱합니다.
    return UserInfo.fromJson(json.decode(response.body));
  } else {
    // 만약 응답이 OK가 아니면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}

// 네트워크 통신 클래스
class UserInfo {
  final int statusCode;
  final String id;
  final String pw;

  UserInfo({required this.statusCode, required this.id, required this.pw});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      statusCode: json['statusCode'],
      id: json['id'],
      pw: json['pw'],
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final List<String> imgList = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
  ];

  final List<String> titles = [
    ' Coffee ',
    ' Bread ',
    ' Gelato ',
    ' Ice Cream ',
    ' Gelato ',
    ' Bread ',
  ];

  int _currentIndex = 0;

  // 참고: https://medium.com/@dev_89267/develop-blockchain-applications-with-flutter-ethereum-59e846944127
  late Future<UserInfo> userInfo;

  // 먼저 UI 요소에 적용할 사용자 정의 텍스트 스타일을 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 18.0);
  TextStyle titleStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 13.0);
  TextStyle contentStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);


  // fetch 메서드를 initState() 혹은 didChangeDependencies() 메서드 안에서 호출하세요.
  //  fetchPost()를 initState()에서 호출하는 이유는?
  // Flutter는 무언가 변경될 때마다 build() 메서드를 호출하는데, 이 호출은 놀랄 만큼 자주 일어납니다.
  // 만약 네트워크 요청 코드를 build() 메서드에 그대로 남겨둔다면, 불필요한 API 요청이 아주 많이 발생하고 앱이 느려질 수 있습니다.
  //  딱 1번만 실행되고 절대 다시는 실행되지 않습니다
  @override
  void initState() {
    super.initState();
    userInfo = fetchUserInfo();

    // 이더리움 클래스 생성
    var ethereum = Ethereum();

    // 이더리움 지갑 연결 테스트
    ethereum.loadContract();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainScrollView(),
    );
  }

  // 메인 스크롤뷰 UI
  Widget mainScrollView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, //  scrollDirection 속성을 사용해 원하는 스크롤 방향을 지정할 수 있습니다.
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // 메인 배너 UI
          Container(
            child: carousel(),
          ),

          // 거래 리스트 제목 UI
          Container(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.alarm),
                SizedBox(width: 5),
                Text("오늘의 상품",
                    textAlign: TextAlign.center,
                    style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),

          // 거래 리스트 UI
          Container(
            child: grid(),
          ),
        ],
      ),
    );
  }

  // 메인 배너 UI - 참고: https://androidride.com/flutter-carousel-slider-example/
  Widget carousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            // enlargeCenterPage: true,
            //scrollDirection: Axis.vertical,
            onPageChanged: (index, reason) {
              setState(
                    () {
                  _currentIndex = index;
                },
              );
            },
          ),
          items: imgList.map((item) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              margin: EdgeInsets.only(
                top: 10.0,
                bottom: 10.0,
              ),
              elevation: 6.0,
              shadowColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: ClipRRect( // 이미지 슬라이더에 활용할 위젯
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
                child: Stack( // 자식들을 쌓아서 배치합니다. Stack의 크기는 자식들의 크기 중 가장 큰 크기에 맞춰집니다.
                  children: <Widget>[
                    Image.network(
                      item, // 해당 url 값을 이미지로
                      fit: BoxFit.cover, // 이미지 채우기
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.map((urlOfItem) {
            int index = imgList.indexOf(urlOfItem);
            return Container(
              width: 7.0,
              height: 7.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Color.fromRGBO(0, 0, 0, 0.8)
                    : Color.fromRGBO(0, 0, 0, 0.3),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // 상품 리스트 UI
  Widget grid() {
    return  GridView(
        physics: ScrollPhysics(), // also important to make your gridview scrollable
        shrinkWrap: true,
        padding: const EdgeInsets.all(5),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            //maxCrossAxisExtent: 200, //  maxCrossAxisExtent: item 하나의 최대 크기를 지정한다.
            mainAxisSpacing: 2, // mainAxisSpacing: 세로item간의 간격을 지정한다.
            crossAxisSpacing: 2, //  crossAxisSpacing: 가로item간의 간격을 지정한다.
            childAspectRatio: 1
        ),
        children: [ // children: GridView에 들어갈 Widget을 지정한다.
          for (int i = 0; i < imgList.length; i++)
            Container(
              // color: Colors.grey,
                padding: const EdgeInsets.all(3.0),
                margin: const EdgeInsets.all(3.0),
                child: Column( // 자식들을 쌓아서 배치합니다. Stack의 크기는 자식들의 크기 중 가장 큰 크기에 맞춰집니다.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect( // 이미지 슬라이더에 활용할 위젯
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      child: Stack( // 자식들을 쌓아서 배치합니다. Stack의 크기는 자식들의 크기 중 가장 큰 크기에 맞춰집니다.
                          children: <Widget>[
                            Image.network(
                              imgList[i], // 해당 url 값을 이미지로
                              fit: BoxFit.cover, // 이미지 채우기
                              width: double.infinity,
                              height: 130,
                            ),
                          ]),
                    ),
                    Text("상품명" ,
                        textAlign: TextAlign.center,
                        style: titleStyle.copyWith(color: Colors.black, fontWeight: FontWeight.normal)
                    ),
                    Text("200,000원",
                        textAlign: TextAlign.center,
                        style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w600)
                    ),
                  ],
                )

            ),
        ]);
  }
}

 */
