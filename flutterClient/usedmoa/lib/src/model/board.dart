class Board {
  final int id;
  final int user_id;
  final String title;
  final String image_url;
  final String product_name;
  final String product_price;
  final String content;
  final String status;
  final String create_date;
  final String update_date;
  final String delete_date;

  Board({this.id, this.user_id, this.title, this.image_url, this.product_name
    , this.product_price, this.content, this.status, this.create_date, this.update_date, this.delete_date});

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as int,
      user_id: json['user_id'] as int,
      title: json['title'] as String,
      image_url: json['image_url'] as String,
      product_name: json['product_name'] as String,
      product_price: json['product_price'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      create_date: json['create_date'] as String,
      update_date: json['update_date'] as String,
      delete_date: json['delete_date'] as String,
    );
  }
}