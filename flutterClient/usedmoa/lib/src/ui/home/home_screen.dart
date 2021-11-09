import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usedmoa/src/bloc/home_bloc.dart';
import 'package:usedmoa/src/bloc/home_event.dart';
import 'package:usedmoa/src/bloc/home_state.dart';


class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}


class _HomeState extends State<Home> {

  // 커스텀 텍스트 스타일 정의
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 18.0);
  TextStyle titleStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 13.0);
  TextStyle contentStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // BlocProvider를 사용하려면 부모 위젯에 BlocProvider 가 생성되어 있어야 한다.
    BlocProvider.of<HomeBloc>(context).add(ListHomesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainScrollView(),
    );
  }

  // 메인 스크롤뷰 UI
  Widget mainScrollView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 원하는 스크롤 방향 설정
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // 거래 리스트 제목 UI
          Container(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.alarm),
                SizedBox(width: 5),
                Text("오늘의 경매",
                    textAlign: TextAlign.center,
                    style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                SizedBox(width: 225),
                Icon(Icons.add_circle_outline),
              ],
            ),
          ),

          // 메인 배너 UI
          Container(
            child: carousel(),
          ),

          // 거래 리스트 제목 UI
          Container(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.alarm),
                SizedBox(width: 5),
                Text("오늘의 상품",
                    textAlign: TextAlign.center,
                    style: style.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                SizedBox(width: 225),
                Icon(Icons.add_circle_outline),
              ],
            ),
          ),

          // 거래 리스트 UI
          Container(
            child: grid(),
          ),
        ],
      ),
    );
  }

  // 메인 배너 UI - 참고: https://androidride.com/flutter-carousel-slider-example/
  Widget carousel() {
    return Column(
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          builder: (_, state) {
            if (state is Empty) {
              return Container(
                child: Text("Empty"),
              );
            } else if (state is Error) {
              return Container(
                child: Text(state.message),
              );
            } else if (state is Loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is Loaded) {
              final items = state.homes;

              return CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: items.map((item) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      margin: EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      elevation: 6.0,
                      shadowColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: ClipRRect(
                        // 이미지 슬라이더에 활용할 위젯
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                        child: Stack(
                          // 자식들을 쌓아서 배치합니다. Stack의 크기는 자식들의 크기 중 가장 큰 크기에 맞춰집니다.
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: item.imageUri, // 해당 url 값을 이미지로
                              width: double.infinity,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover, // 이미지 채우기
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )).toList());
            } else {
              return Container();
            }
          },
        ),
        BlocBuilder<HomeBloc, HomeState>(
          builder: (_, state) {
            if (state is Empty) {
              return Container();
            } else if (state is Error) {
              return Container(
                child: Text(state.message),
              );
            } else if (state is Loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is Loaded) {
              final items = state.homes;

              // Page Control UI 설정
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: items.map((urlOfItem) {
                  int index = items.indexOf(urlOfItem);
                  return Container(
                    width: 7.0,
                    height: 7.0,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Color.fromRGBO(0, 0, 0, 0.8)
                          : Color.fromRGBO(0, 0, 0, 0.3),
                    ),
                  );
                }).toList(),
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  // 오늘의 상품 UI 설정
  Widget grid() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        if (state is Empty) {
          return Container();
        } else if (state is Error) {
          return Container(
            child: Text(state.message),
          );
        } else if (state is Loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is Loaded) {
          final items = state.homes;

          return GridView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(5),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2, // mainAxisSpacing: 세로item간의 간격을 지정한다.
                  crossAxisSpacing: 2, // crossAxisSpacing: 가로item간의 간격을 지정한다.
                  childAspectRatio: 1),
              children: [
                // children: GridView에 들어갈 Widget을 지정한다.
                for (int i = 0; i < items.length; i++)
                  Container(
                      padding: const EdgeInsets.all(3.0),
                      margin: const EdgeInsets.all(3.0),
                      child: Column(
                        // 자식들을 쌓아서 배치합니다. Stack의 크기는 자식들의 크기 중 가장 큰 크기에 맞춰집니다.
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            // 이미지 슬라이더에 활용할 위젯
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            child: Stack(
                              // 자식들을 쌓아서 배치합니다. Stack의 크기는 자식들의 크기 중 가장 큰 크기에 맞춰집니다.
                                children: <Widget>[
                                  CachedNetworkImage(
                                    imageUrl: items[i].imageUri, // 해당 url 값을 이미지로
                                    height: 130,
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover, // 이미지 채우기
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),

                                  // Image.network(
                                  //   items[i].imageUri, // 해당 url 값을 이미지로
                                  //   fit: BoxFit.cover, // 이미지 채우기
                                  //   width: double.infinity,
                                  //   height: 130,
                                  // ),
                                ]),
                          ),
                          Text(items[i].productName,
                              textAlign: TextAlign.center,
                              style: titleStyle.copyWith(color: Colors.black, fontWeight: FontWeight.normal)),
                          Text(items[i].productPrice,
                              textAlign: TextAlign.center,
                              style: contentStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w600)),
                        ],
                      )),
              ]);
        } else {
          return Container();
        }
      },
    );
  }
}