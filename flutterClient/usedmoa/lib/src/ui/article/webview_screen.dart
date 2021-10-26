import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:webview_flutter/webview_flutter.dart';


class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}


class WebViewScreen extends StatefulWidget {
  int board_id;

  WebViewScreen(board_id) {
    this.board_id = board_id;
  }

  @override
  _WebViewState createState() => _WebViewState(board_id);
}


class _WebViewState extends State<WebViewScreen> {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  SharedPreferences prefs;
  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  int board_id;

  _WebViewState(int board_id) {
    this.board_id = board_id;
  }


  // 딱 1번만 실행되고 절대 다시는 실행되지 않습니다
  @override
  void initState() {
    super.initState();
    print("initState 실행");

    _userInfo();
  }


  // 사용자 정보 조회
  _userInfo() async {
    prefs = await SharedPreferences.getInstance();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영상통화'),
      ),
      body: Builder(builder: (BuildContext context) {
        return InAppWebView( // 참고 : https://inappwebview.dev/docs/javascript/communication/
            initialUrlRequest: URLRequest(url: Uri.parse("https://www.usedmoa.co.kr:5000")),
            initialOptions: options,
            onWebViewCreated: (controller) {
              print("onWebViewCreated 실행");
              webViewController = controller;
            },
            onLoadStop: (controller, url) async {
              print("onLoadStop 실행");

              // JavaScript 핸들러를 등록
              // handlerName는 호출하는 핸들러 이름을 나타내는 문자열
              // argsFlutter 측에 보낼 수 있는 선택적 인수
              // 버블링이 일어나면서 document에서 이벤트가 처리됨
              await controller.evaluateJavascript(source: """
              window.addEventListener("myCustomEvent", (event) => {
                createSession(${prefs.getString("user_id") ?? ""}, ${board_id});
                console.log("detail: ",JSON.stringify(event.detail));
                joinSession();
              }, false);
              """);

              // 이벤트(myCustomEvent)를 만들고 window 에서 이벤트 디스패치
              await controller.evaluateJavascript(source: """
                const event = new CustomEvent("myCustomEvent", {
                detail: {foo: 1, bar: false}
                });
                window.dispatchEvent(event);
              """);
            },
            onConsoleMessage: (controller, consoleMessage) {
              print("onConsoleMessage 실행");
              print(consoleMessage);
              // it will print: {message: {"bar":"bar_value","baz":"baz_value"}, messageLevel: 1}
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              await webViewmain();
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            }
        );
      }),
    );
  }


  @override
  void dispose() {
    super.dispose();
    print("dispose 실행");

    browserClose();
  }


  Future browserClose() async {
    print("browserClose 실행");
    // 이벤트(myCustomEvent)를 만들고 window 에서 이벤트 디스패치
    final String functionBody = """
    var p = new Promise(function (resolve, reject) {
    removeUser(); 
    closeSession();
    leaveSession();
    });
    await p;
    return p;
    """;

    var result =  await webViewController.callAsyncJavaScript(
        functionBody: functionBody,
        arguments: {'x': 49, 'y': 'my error message'});
    print("result : ${result}"); // {value: 49, error: null}

    //webViewController.
    //browser.close();
  }
}

Future webViewmain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.storage.request();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
      AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      );
    }
  }
}