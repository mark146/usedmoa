/*
예제 1
// 참고: https://ahang.tistory.com/12
  // 가로
  scrollDirection: Axis.horizontal, //  scrollDirection 속성을 사용해 원하는 스크롤 방향을 지정할 수 있습니다.
  child: Row(
Widget mainScrollView() {

  return SingleChildScrollView(
    scrollDirection: Axis.vertical, //  scrollDirection 속성을 사용해 원하는 스크롤 방향을 지정할 수 있습니다.
    padding: const EdgeInsets.all(5),
    child: Column(
      children: [
        Container(
          // width: _rowWidth,
          color: Colors.amberAccent,
          child: carousel3(),
        ),
        Container(
          // width: _rowWidth,
          height: _rowHeight,
          color: Colors.blueAccent,
        ),
        Container(
          // width: _rowWidth,
          height: _rowHeight,
          color: Colors.redAccent,
        ),
      ],
    ),
  );
}
 */
