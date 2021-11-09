import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usedmoa/src/model/board.dart';
import 'package:usedmoa/src/ui/article/webview_screen.dart';


class ItemDetail extends StatefulWidget {

  Board itemInfo;

  // 기본 생성자: 변수 선언 후 초기화 및 입력 - 참고: https://brunch.co.kr/@mystoryg/123
  ItemDetail(this.itemInfo) {
    itemInfo = itemInfo;
  }

  @override
  _ItemDetailState createState() => _ItemDetailState(itemInfo);
}


class _ItemDetailState extends State<ItemDetail> {
  StreamController<String> streamController = StreamController<String>();

  // shared preferences 얻기
  SharedPreferences prefs;

  var money;
  BuildContext detailContext;
  Board itemInfo;

  // 먼저 UI 요소에 적용할 사용자 정의 텍스트 스타일을 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 17.0);
  TextStyle titleStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 17.0);
  TextStyle contentStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);

  _ItemDetailState(Board itemInfo) {
    this.itemInfo = itemInfo;
  }


  //  딱 1번만 실행되고 절대 다시는 실행되지 않습니다
  @override
  void initState() {
    super.initState();

    print("title: ${itemInfo}");

    getTokenInfoRequest();
  }

  // 토큰 정보 조회
  Future<String> getTokenInfoRequest() async {
    var dio = Dio();
    final response = await dio.get(
        'https://www.usedmoa.co.kr/users/tokenAmount',
        queryParameters: {'userId': "master"}
    );

    money = response.data["amount"];
    return response.data["amount"];
  }

  // 참고: https://here4you.tistory.com/111
  @override
  Widget build(BuildContext context) {
    this.detailContext = context;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('상품 상세보기', textAlign: TextAlign.center),
      ),
      body: mainScrollView(),
    );
  }


  // 메인 스크롤뷰 UI
  Widget mainScrollView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 원하는 스크롤 방향 지정
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // 사진 UI
          Container(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
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
                    child: Container(
                      height: (MediaQuery.of(context).size.height/3),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black12,
                      child: CachedNetworkImage(
                        imageUrl: itemInfo.image_url, // 해당 url 값을 이미지로
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover, // 이미지 채우기
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

          // 상품글 제목 UI
          Container(
              padding: const EdgeInsets.only(top: 5, left: 20, right: 0, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text("[${itemInfo.status}] "+itemInfo.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              )
          ),

          // 상품글 가격, 영상통화 버튼 UI
          Container(
            padding: const EdgeInsets.only(top: 0, left: 20, right: 0, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                // 가격 UI
                Flexible(child:
                Text("${itemInfo.product_price} 원", textAlign: TextAlign.center,
                    style: titleStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ),

                // 중간 공백 UI
                Expanded(
                  flex: 2,
                  child: SizedBox(width: (MediaQuery.of(context).size.width/5)),
                ),

                // 영상통화 버튼 UI
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: onJoin,
                    child: Text('영상통화'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                        foregroundColor: MaterialStateProperty.all(Colors.white)
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 상품글 내용 UI
          Container(
            padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
            child: Container(
              height: (MediaQuery.of(context).size.height/4),
              width: (MediaQuery.of(context).size.width),
              child:
              Expanded(
                  child: Container(
                    child: TextField(
                      autocorrect: true,
                      readOnly: true,
                      maxLines: null,
                      controller: TextEditingController(text: itemInfo.content),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(width: 1, color: Colors.black12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  )
              ),
            ),
          ),

          // 결제 버튼 UI
          Container(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 2),

            child: MaterialButton( // 위젯을 자식으로 사용하는 재료 위젯을 자식으로 추가
              minWidth: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              onPressed: () {
                print("결제 이벤트 실행");
                FlutterDialog();
              },
              child: Text("거래 하기",
                  textAlign: TextAlign.center,
                  style: titleStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }


  // 영상통화 UI 이동
  Future<void> onJoin() async {
    print("onJoin 실행 - 영상통화 UI 이동");
    //board_id
    // await Navigator.pushNamed(context, '/meeting')
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewScreen(itemInfo.id))).then((value) {
      if (value == true) {
        print("setState");
      }
    });
  }


  void FlutterDialog() {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                new Text("결제창"),
              ],
            ),

            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                // 결제방법 UI
                Container(
                  padding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Expanded(
                        flex: 2,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("결제방법",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      fontStyle: FontStyle.normal)
                              ),
                            ]
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                              "보유 금액",
                              textAlign: TextAlign.center,
                              style: style.copyWith(color: Colors.black,
                                  fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                SizedBox(height: 5),

                // 결제방법 UI
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // 가로축 정렬 속성
                    //  Container 배치순서를 바꾸지 않고 간격을 바꾸고 싶을때 사용
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("이더리움",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 15,
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
                          child: Text(
                              "${money} 원",
                              maxLines : 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal, letterSpacing: 0.5)
                          ),
                        ),
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
                          child: Text("${itemInfo.product_price} 원", textAlign: TextAlign.center),
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
                          child: Text("${itemInfo.product_price} 원", textAlign: TextAlign.center,
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
        // var ethereum = Ethereum();
        // ethereum.sendTokens(2000);

        
        // dio 서버 결제 요청
        
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
}