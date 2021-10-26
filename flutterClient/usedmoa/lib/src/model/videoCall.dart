class VideoCall {
  final int video_id;
  final String title;
  final String image_url;
  final String video_url;
  final String create_date;


  VideoCall({this.video_id, this.title, this.image_url, this.video_url,
    this.create_date});


  factory VideoCall.fromJson(Map<String, dynamic> json) {
    return VideoCall(
      video_id: json['video_id'] as int,
      title: json['title'] as String,
      image_url: json['image_url'] as String,
      video_url: json['video_url'] as String,
      create_date: json['create_date'] as String,
    );
  }
}