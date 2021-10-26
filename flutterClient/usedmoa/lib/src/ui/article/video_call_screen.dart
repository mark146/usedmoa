import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

/*
// 참고:https://www.agora.io/en/blog/add-video-calling-to-your-flutter-app-using-agora/
class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;

  /// non-modifiable client role of the page
  final ClientRole? role;

  /// Creates a call page with given channel name.
  const CallPage({Key? key, this.channelName, this.role}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  List<String> _chatList = <String>[];
  bool muted = false;
  late RtcEngine _engine;

  StreamController<String> streamController = StreamController<String>();
  StreamController<String> timerController = StreamController<String>();
  List<String> reverseList = <String>[];

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // initialize agora sdk
    initialize();
  }

  // 참ㄱ고: https://dart.dev/tools/diagnostic-messages#extra_positional_arguments_could_be_named
  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _chatList.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _chatList.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Token, widget.channelName!, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          streamController.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          // final info = 'onJoinChannel: $channel, uid: $uid';
          final info = '$uid 님이 접속하셨습니다.';
          streamController.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          final info = '채널을 나가셨습니다.';
          streamController.add(info);
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          // final info = 'userJoined: $uid';
          final info = '$uid 님이 접속하셨습니다.';
          streamController.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        setState(() {
          // final info = 'userOffline: $uid';
          final info = '$uid 님이 나가셨습니다.';
          streamController.add(info);
          _users.remove(uid);
        });
      },
    ));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(left: 0, top: 5, right: 0, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            //padding: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.all(7.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            // padding: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            // padding: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.all(7.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        //  heightFactor와 heightFactor은 Center의 부모 Widget의 크기를 child의 Widget size * Factor 로 지정 할 수 있다.
        // 만약 null이면 부모 Widget은 최대 크기로 지정이 된다.
        heightFactor: 0.4,
        child: Container(
          decoration: BoxDecoration(
            // color: Colors.yellowAccent, // 배경색
            borderRadius: BorderRadius.circular(5), //모서리를 둥글게
            // border: Border.all(color: Colors.black12, width: 3) //테두리
          ),

          // 참고: https://greedy0110.tistory.com/42
          child: StreamBuilder(
            stream: streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // print("snapshot.hasData: ${snapshot.hasData} snapshot: ${snapshot.data}");
                //
                // reverseList.add(snapshot.data.toString());
                //
                // List<String> reversed = reverseList.reversed.toList();
                // return ListView.builder(
                //   reverse: true,
                //   itemCount: reverseList.length,
                //   itemBuilder: (BuildContext context, int index) {
                //     return Padding(
                //       padding: const EdgeInsets.symmetric(
                //         vertical: 3,
                //         horizontal: 10,
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Flexible(
                //             child: Container(
                //               padding: const EdgeInsets.symmetric(
                //                 vertical: 2,
                //                 horizontal: 5,
                //               ),
                //               decoration: BoxDecoration(
                //                 // color: Colors.yellowAccent, // 배경색
                //                   borderRadius: BorderRadius.circular(5), //모서리를 둥글게
                //                   border: Border.all(color: Colors.black12, width: 3) //테두리
                //               ),
                //               child: Text(
                //                   reversed[index],
                //                   style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 15, fontStyle: FontStyle.normal)
                //               ),
                //             ),
                //           )
                //         ],
                //       ),
                //     );
                //   },
                // );

                return Text("null");
              } else {
                return Text("null");
              }
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영상 통화',
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal)),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
*/