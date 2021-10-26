// 출처: https://pythonkim.tistory.com/121 [파이쿵]
/*
void main() => runApp(MaterialApp(title: 'MyApp', home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}


class _MyApp extends State<MyApp> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BottomNavigationBar'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey, // Bar의 배경색
        selectedItemColor: Colors.redAccent, //선택된 아이템의 색상
        unselectedItemColor: Colors.white.withOpacity(.60), // 선택 안된 아이템의 색상
        selectedFontSize: 14, // 선택된 아이템의 폰트사이즈
        unselectedFontSize: 14, // 선택 안된 아이템의 폰트사이즈
        currentIndex: _selectedIndex, //현재 선택된 Index
        onTap: (int index) { // 눌렀을 경우 어떻게 행동할지
          setState(() { // setState()를 추가하여 인덱스를 누를때마다 빌드를 다시함
            _selectedIndex = index; // index는 처음 아이템 부터 0, 1, 2, 3
          });
        },
        items: [
          BottomNavigationBarItem(
            title: Text('Favorites'),
            icon: Icon(Icons.favorite),
          ),
          BottomNavigationBarItem(
            title: Text('Music'),
            icon: Icon(Icons.music_note),
          ),
          BottomNavigationBarItem(
            title: Text('Places'),
            icon: Icon(Icons.location_on),
          ),
          BottomNavigationBarItem(
            title: Text('News'),
            icon: Icon(Icons.library_books),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  List _widgetOptions = [
    Text(
      'Favorites',
      style: TextStyle(fontSize: 30, fontFamily: 'DoHyeonRegular'),
    ),
    Text(
      'Music',
      style: TextStyle(fontSize: 30, fontFamily: 'DoHyeonRegular'),
    ),
    Text(
      'Places',
      style: TextStyle(fontSize: 30, fontFamily: 'DoHyeonRegular'),
    ),
    Text(
      'News',
      style: TextStyle(fontSize: 30, fontFamily: 'DoHyeonRegular'),
    ),
  ];
}
*/
