import 'package:freezed_annotation/freezed_annotation.dart';

part 'home.freezed.dart';
part 'home.g.dart';

// freezed - 참고 : https://codewithandrea.com/articles/parse-json-dart-codegen-freezed/
@freezed
class Home with _$Home {
  factory Home({
    String productName,
    String productPrice,
    String imageUri,
  }) = _Home;

  factory Home.fromJson(Map<String, dynamic> json) => _$HomeFromJson(json);
}
