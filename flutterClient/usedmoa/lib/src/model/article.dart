import 'package:freezed_annotation/freezed_annotation.dart';


part 'article.freezed.dart';
part 'article.g.dart';

// freezed - 참고 : https://codewithandrea.com/articles/parse-json-dart-codegen-freezed/
@freezed
class Article with _$Article {
  factory Article({
    String productName,
    String productPrice,
    String imageUri,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
}
