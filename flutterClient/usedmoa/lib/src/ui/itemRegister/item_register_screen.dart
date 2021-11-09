import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';


class ItemRegister extends StatefulWidget {
  @override
  _ItemRegisterState createState() => _ItemRegisterState();
}


class _ItemRegisterState extends State<ItemRegister> {

  // 텍스트 스타일을 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 25.0);

  Color kDarkGray = Color(0xFFA3A3A3);
  Color kLightGray = Color(0xFFF1F0F5);

  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFileList = [];

  SharedPreferences prefs;

  StreamController<String> uiController = StreamController<String>();
  TextEditingController _title;
  TextEditingController _product_name;
  TextEditingController _product_price;
  TextEditingController _content;


  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _product_name = TextEditingController();
    _product_price = TextEditingController();
    _content = TextEditingController();
    uiController.add("");
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
      scrollDirection: Axis.vertical, // 원하는 스크롤 방향 설정
      padding: const EdgeInsets.all(5),
      child: StreamBuilder(
        stream: uiController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("snapshot.data: ${snapshot.data}");
            return contentView();
          } else {
            return contentView();
          }
        },
      ),
    );
  }


  // 내용 UI
  Widget contentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [

        // 일반 상품 등록하기 UI
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm),
                  SizedBox(width: 5),
                  Text("일반 상품 등록하기",
                      textAlign: TextAlign.center,
                      style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 15),


        // 상품 이미지 추가 UI
        Container(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFileList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddPhoto();
              }
              return Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      print('선택한 사진 제거 : ${_imageFileList[index - 1]}');

                      setState(() {
                        _imageFileList.remove(_imageFileList[index - 1]);
                      });
                    },
                    child: Container(
                        margin: EdgeInsets.all(5),
                        height: 100,
                        width: 100,
                        color: kLightGray,
                        child: Image.file(File(_imageFileList[0].path))
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 15),


        // 제목 UI
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: TextField(
            controller: _title,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.assignment),
              labelText: '제목',
              hintText: '제목을 입력해주세요.',
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.black),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onSubmitted : (text) {
              _title.text = text;
              FocusScope.of(context).unfocus();
            },
            keyboardType: TextInputType.name,
          ),
        ),
        SizedBox(height: 15),


        // 상품명 UI
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: TextField(
            controller: _product_name,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.assignment),
              labelText: '상품명',
              hintText: '상품명을 입력해주세요.',
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.black),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onSubmitted : (text) {
              _product_name.text = text;
              FocusScope.of(context).unfocus();
            },
            keyboardType: TextInputType.name,
          ),
        ),
        SizedBox(height: 15),


        // 판매 금액 UI
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: TextField(
            controller: _product_price,
            decoration: InputDecoration(
              hintText: '0',
              labelText: '판매금액',
              prefixIcon: Icon(Icons.attach_money),
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.black),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onSubmitted : (text) {
              _product_price.text = text;
              FocusScope.of(context).unfocus();
            },
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(height: 15),


        // 상품 내용 UI
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: TextField(
            controller: _content,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.article_outlined),
              labelText: '상품 내용',
              hintText: '상품 내용을 작성해주세요.',
              labelStyle: TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.black),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onSubmitted : (text) {
              _content.text = text;
              FocusScope.of(context).unfocus();
            },
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 1,
            maxLines: 10,
          ),
        ),
        SizedBox(height: 15),


        // 등록 완료 버튼 UI
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
          child: Material(
            elevation: 5.0, // 버튼에 그림자 추가
            borderRadius: BorderRadius.circular(30.0), // 테두리 둥글게 설정
            color: Colors.grey,
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
              onPressed: () {
                print("등록하기 버튼 클릭");
                PostData();
              },
              child: Text("등록하기",
                  textAlign: TextAlign.center,
                  style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }


  // 비동기로 갤러리 이미지를 선택하는 함수 - 참고: https://ichi.pro/ko/flutterleul-sayonghayeo-aws-s3e-imiji-eoblodeu-1-bu-161375559492658
  Future _getImage() async {
    try {
      // pickMultiImage() 메서드로 이미지(XFile) 리스트를 받아옴
      final pickedFileList = await _picker.pickMultiImage();

      // 이미지 UI 수정
      setState(() {
        _imageFileList = pickedFileList;
      });
    } catch (e) {
      print("_getImage - error: ${e}");
    }
  }


  _buildAddPhoto() {
    return InkWell(
      onTap: () => _onAddPhotoClicked(context),
      child: Container(
        margin: EdgeInsets.all(5),
        height: 100,
        width: 100,
        color: kDarkGray,
        child: Center(
          child: Icon(Icons.add_to_photos, color: kLightGray),
        ),
      ),
    );
  }


  // 사진 권한 요청 함수
  _onAddPhotoClicked(context) async {
    Permission permission;

    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    if (Platform.isAndroid) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }


    PermissionStatus permissionStatus = await permission.status;

    print(permissionStatus);

    if (permissionStatus == PermissionStatus.restricted) {
      // _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      // _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }


    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
        // _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      print('Permission granted');
      _getImage();

    }
  }


  // 이미지 s3 업로드
  Future<int> uploadImage(uploadUrl) async {
    try {
      File image = File(_imageFileList[0].path);

      var response = await http.put(Uri.parse(uploadUrl), body: image.readAsBytesSync());
      return response.statusCode;
    } catch (e) {
      throw ('Error uploading photo: ${e}');
    }
  }


  // 등록완료 버튼 클릭 - https://github.com/flutterchina/dio
  Future<void> PostData() async {

    if(_imageFileList != null && _imageFileList.isEmpty) {
      print("_imageFileList!.isEmpty : ${_imageFileList.isEmpty}");
    } else {
      prefs = await SharedPreferences.getInstance();
      String user_id = prefs.getString("user_id") ?? "";
      String accessToken = prefs.getString("accessToken") ?? "";
      String refreshToken = prefs.getString("refreshToken") ?? "";


      Map<String, dynamic> json = new Map();
      json["user_id"] = user_id;
      json["imageUrl"] = _imageFileList[_imageFileList.length-1].path;


      // 토큰 정보들 조회
      print("accessToken : ${accessToken}");
      print("refreshToken : ${refreshToken}");


      // 서버에 글 등록 요청
      var response = await createRequest(accessToken, json);
      // print("response : ${response}");


      if(response.statusCode != 200) {
        // print("response.data[statusCode] : ${response.data["statusCode"]}");
        print("response.data[message] : ${response.data["message"]}");
        var result;
        switch(response.data["message"]) {
          case "JsonWebTokenError" :
            result = refreshTokenRequest(accessToken, refreshToken);
            print("JsonWebTokenError - result : ${result}");
            print("JsonWebTokenError - accessToken : ${response.headers.value("accesstoken") ?? ""}");
            print("JsonWebTokenError - refreshToken : ${response.headers.value("refreshtoken") ?? ""}");

            // shared preferences 호출 후 값 저장
            // final prefs = await SharedPreferences.getInstance();
            // prefs.setString('accessToken', response.headers.value("accesstoken") ?? "");
            // prefs.setString('refreshToken', response.headers.value("refreshtoken") ?? "");
            break;
          case "TokenExpiredError" :
            result = refreshTokenRequest(accessToken, refreshToken);
            print("TokenExpiredError - result : ${result}");
            print("TokenExpiredError - accessToken : ${response.headers.value("accesstoken") ?? ""}");
            print("TokenExpiredError - refreshToken : ${response.headers.value("refreshtoken") ?? ""}");

            // shared preferences 호출 후 값 저장
            // final prefs = await SharedPreferences.getInstance();
            // prefs.setString('accessToken', response.headers.value("accesstoken") ?? "");
            // prefs.setString('refreshToken', response.headers.value("refreshtoken") ?? "");
            break;
          default:
          // todo - 기타 에러 요청 처리
        }
        // 서버에 글 등록 요청
        response = await createRequest(prefs.get("accessToken"), json);
        print("response : ${response}");


      } else {

        // 이미지 s3 업로드
        var result = await uploadImage(response.data['uploadUrl']);
        print("이미지 s3 업로드 - result: ${result}");

        // 입력창 리셋 다이얼로그 띄우기
        if(result == 200) {
          setState(() {
            if(_title != null) {
              _title.clear();
            }
            if(_product_name != null) {
              _product_name.clear();
            }
            if(_product_price != null) {
              _product_price.clear();
            }
            if(_content != null) {
              _content.clear();
            }

            _imageFileList.clear();
          });

          FlutterDialog();
        }
      }
    }
  }


  // 서버에 글 등록 요청
  Future<Response<dynamic>> createRequest(accessToken, json) async {
    // print("json 값 : ${json}");
    // print("_title.text 값 : ${_title.text}");
    // print("_product_name.text 값 : ${_product_name.text}");
    // print("_product_price.text 값 : ${_product_price.text}");
    // print("_content.text 값 : ${_content.text}");

    print("prefs.getString(kakaoUserId) : ${prefs.getString("kakaoUserId") ?? ""}");
    print("prefs.getString(user_id) : ${prefs.getString("user_id") ?? ""}");
    print("prefs.getString(refreshToken) : ${prefs.getString("refreshToken") ?? ""}");

    Response<dynamic> response;
    try {
      var dio = Dio();
      response = await dio.post(
          'https://www.usedmoa.co.kr/board/create',
          options: Options(
            headers: {"authorization": "Bearer $accessToken"},
          ),
          data: {
            'user_id' : json["user_id"],
            'image_url' : json["imageUrl"],
            'title' : _title.text,
            'product_name' : _product_name.text,
            'product_price' : _product_price.text,
            'content' : _content.text,
          });
      print("createRequest - response.statusCode: ${response.statusCode}");

      // 참고 : https://github.com/flutterchina/dio#examples
    } on DioError catch (error) {
      if (error.response != null) {
        print("error.response.data: ${error.response.data}");
      } else {
        print("error.message: ${error.response}");
      }
      response = error.response;
    }


    // print("서버 요청 결과 - headers: ${response}");
    // print("서버 요청 결과 - statusCode: ${response.statusCode}");
    // print("서버 요청 결과 - headers(accesstoken): ${response.headers.value("accesstoken")}");
    // print("서버 요청 결과 - headers(refreshtoken): ${response.headers.value("refreshtoken")}");
    print("서버 요청 결과 - data: ${response.data}");
    return response;
  }


  // 엑세스 토큰 요청 - 참고 : https://github.com/flutterchina/dio#examples
  Future<Response<dynamic>> refreshTokenRequest(accessToken, refreshToken) async {

    Response<dynamic> response;
    try {
      List<Cookie> cookies = [
        new Cookie("refresh", prefs.getString("refreshToken") ?? ""),
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
              }),
          data: {
            'user_id' : prefs.getString("user_id") ?? "",
          }
      );
      print("response: ${response}");
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


  // 다이얼로그 창 띄우기
  void FlutterDialog() {
    showDialog(
        context: context,
        barrierDismissible: false, // Dialog를 제외한 다른 화면 터치 x 설정
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),// Dialog 화면 모서리 둥글게 조절
            title: Column(children: <Widget>[
              Text("알림창"),
            ]),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15),

                Divider(),

                // 총 결제금액 UI
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, // 가로축 정렬 속성
                    children: <Widget>[
                      Center(
                        child: Text("상품등록이 완료되었습니다.",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal, letterSpacing: 0.5)
                        ),
                      ),
                    ]
                ),
              ],
            ),

            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 14)),
                  foregroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                child: Text("확인"),
              ),
            ],
          );
        });
  }
}