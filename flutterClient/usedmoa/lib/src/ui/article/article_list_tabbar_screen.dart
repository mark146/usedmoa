import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'auction_list_screen.dart';
import 'item_list_screen.dart';


// 참고 : https://github.com/nisrulz/flutter-examples/blob/develop/using_tabs/lib/main.dart
class ArticleListTabBar extends StatefulWidget {
  @override
  _ArticleListTabBarState createState() => _ArticleListTabBarState();
}


class _ArticleListTabBarState extends State<ArticleListTabBar> with SingleTickerProviderStateMixin {

  TabController controller;

  // 커스텀 텍스트 스타일 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 17.0);


  @override
  void initState() {
    super.initState();

    controller = TabController(length: 2, vsync: this);
  }


  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }


  TabBar getTabBar() {
    return TabBar(
      tabs: <Tab>[
        Tab(child: Text("중고 상품",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white, fontWeight: FontWeight.normal)
        )
        ),
        Tab(child: Text("경매 상품",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white, fontWeight: FontWeight.normal)
        ),
        ),
      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView(var tabs) {
    return TabBarView(
      children: tabs,
      controller: controller,
    );
  }

  // -------------------- Setup the page by setting up tabs in the body ------------------*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
              backgroundColor: Colors.blue,
              bottom: getTabBar()),
        ),
        body: getTabBarView(<Widget>[
          ItemList(), // 일반 상품 목록 UI
          AuctionList(), // 경매 상품 목록 UI
        ]));
  }
}