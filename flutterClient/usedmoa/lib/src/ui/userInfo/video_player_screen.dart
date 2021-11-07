import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usedmoa/src/model/videoCall.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerScreen extends StatefulWidget {
  VideoCall videoInfo = new VideoCall();

  VideoPlayerScreen(VideoCall videoCallList) {
    this.videoInfo = videoCallList;
  }

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState(videoInfo);
}


class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  VideoCall videoInfo;


  _VideoPlayerScreenState(VideoCall videoInfo) {
    this.videoInfo = videoInfo;
  }


  @override
  void initState() {
    // VideoPlayerController를 저장하기 위한 변수를 생성.
    // VideoPlayerController : asset, file, network 등 영상들을 제어하기 위해 다양한 생성자 제공.
    // _controller = VideoPlayerController.asset('assets/videos/butterfly.mp4'); //file play
    _controller = VideoPlayerController.network(
      videoInfo.video_url,
      //'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', //live play
    );

    // initialize() : 지정된 dataSource 열고 비디오에 대한 metadata load
    // 컨트롤러를 초기화하고 추후 사용하기 위해 Future를 변수에 할당.
    _initializeVideoPlayerFuture = _controller.initialize();

    // 비디오를 반복 재생하기 위해 컨트롤러를 사용.
    _controller.setLooping(true);

    super.initState();
  }


  @override
  void dispose() {
    // 자원을 반환하기 위해 VideoPlayerController dispose.
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영상통화 내용'),
      ),
      // FutureBuilder : VideoPlayerController가 초기화 진행하는 동안 로딩 스피너를 보여주기 위함
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          // ConnectionState : 비동기 계산에 대한 연결 상태
          if (snapshot.connectionState == ConnectionState.done) {
            // VideoPlayerController 초기화 끝나면, 제공된 데이터 사용하여 VideoPlayer 종횡비 제한.
            return AspectRatio(
              // aspectRatio: _controller.value.aspectRatio,
               aspectRatio: 26/20,
              // 영상 보여주기 위해 VideoPlayer 위젯 사용.
              child: VideoPlayer(_controller),
            );
          } else {
            // 만약 VideoPlayerController가 여전히 초기화 중이라면, 로딩 스피너를 보여줌.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 재생/일시 중지 기능을 setState에 넣음. 아이콘 변경 위함
          setState(() {
            // 영상 재생 중이라면, 일시 중지.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // 만약 영상 일시 중지 상태였다면, 재생.
              _controller.play();
            }
          });
        },
        // 플레이어 상태에 따라 올바른 아이콘 보여줌.
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ), // 이 마지막 콤마는 build 메서드에 자동 서식이 잘 적용될 수 있도록 도와줌.
    );
  }
}