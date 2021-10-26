import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usedmoa/src/bloc/home_bloc.dart';
import 'package:usedmoa/src/repository/home_repository.dart';
import 'package:usedmoa/src/ui/userInfo/setting_screen.dart';
import 'package:usedmoa/src/ui/home/home_screen.dart';
import 'article/article_list_tabbar_screen.dart';
import 'itemRegister/item_register_tabbar_screen.dart';


// 참고: https://stackoverflow.com/questions/50580234/flutter-navigation-drawer-hamburger-icon-color-change
class BottomNavigation extends StatefulWidget {
  BottomNavigation({Key key, this.title}) : super(key: key); // 생성자

  final String title;

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}


class _BottomNavigationState extends State<BottomNavigation> {

  // 커스텀 텍스트 스타일 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final pageController = PageController();

  int _currentIndex = 0;

  // 선택시 보여줄 탭 화면 리스트
  final List<Widget> _children = [
    BlocProvider( // bloc 초기화
        create: (_) => HomeBloc(repository: HomeRepository()),
        child: Home()),
    ItemRegisterTabBar(),
    ArticleListTabBar(),
    Setting()
  ];

  // 바텀네비게이션 아이콘 클릭 이벤트
  void _onTap(int index) {
    pageController.jumpToPage(index);
  }

  // 바텀네비게이션 아이콘 클릭시 화면 전환 이벤트 실행
  // index는 처음 아이템 부터 0, 1, 2, 3
  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(widget.title,
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: <Widget>[
          IconButton(
            icon: Image.asset("assets/icons/notification.png", width: 30, height: 30),
            tooltip: 'Go to the next page',
            onPressed: () {
              print('알림 이벤트 실행');
            },
          ),
        ],
      ),

      // 내용 UI 설정
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: _children,
        physics: NeverScrollableScrollPhysics(), // No sliding
      ),

      // 네비게이션 드로어 설정 - 참고: https://dev-yakuza.posstree.com/ko/flutter/navigator/drawer/
      // drawer에는 기본적으로 Drawer 위젯을 지정해야 합니다. Darwer 위젯은 하나의 자식 위젯을 가질 수 있습니다.
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // 헤더 UI 설정
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/mountain.jpg'),
              ),
              accountEmail: Text('dev.yakkuza@gmail.com'),
              accountName: Text('Dev Yakuza'),
              // onDetailsPressed: () {
              //   print('press details');
              // },
              decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text('Item 1'),
              onTap: () {
                Navigator.pop(context); // 드로워를 닫는다.
              },
            ),

            ListTile(
              leading: Icon(Icons.analytics_outlined),
              title: Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // 바텀 네비게이션 설정
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        // Bar의 배경색
        selectedItemColor: Colors.blue,
        //선택된 아이템의 색상
        unselectedItemColor: Colors.black.withOpacity(.60),
        // 선택 안된 아이템의 색상
        selectedFontSize: 16,
        // 선택된 아이템의 폰트사이즈
        unselectedFontSize: 14,
        // 선택 안된 아이템의 폰트사이즈
        currentIndex: _currentIndex,
        //현재 선택된 Index
        onTap: _onTap,
        // 눌렀을 경우 어떻게 행동할지
        items: [
          // 바텀 네비게이션 아이콘 UI 설정
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '상품 등록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: '게시글',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: '내정보',
          ),
        ],
      ),
    );
  }
}