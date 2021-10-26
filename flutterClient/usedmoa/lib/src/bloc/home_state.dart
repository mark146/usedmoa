import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:usedmoa/src/model/home.dart';

// state에서는 각 bloc에 대한 상태등을 정의해 준다.
// bloc는 data와 연결되고 event를 처리하여 state를 관리하는 역할을 합니다.
@immutable
abstract class HomeState extends Equatable {}

class Empty extends HomeState {
  @override
  List<Object> get props => [];
}

class Loading extends HomeState {
  @override
  List<Object> get props => [];
}

class Error extends HomeState {
  final String message;

  Error({
    this.message,
  });

  @override
  List<Object> get props => [this.message];
}

class Loaded extends HomeState {
  final List<Home> homes;

  Loaded({
    this.homes,
  });

  @override
  List<Object> get props => [this.homes];
}
