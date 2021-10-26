import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
//import 'package:test_app/example/model/todo.dart';

// bloc는 data와 연결되고 event를 처리하여 state를 관리하는 역할을 합니다.
@immutable
abstract class TodoState extends Equatable {}
/*
class Empty extends TodoState {
  @override
  List<Object?> get props => [];
}

class Loading extends TodoState {
  @override
  List<Object?> get props => [];
}

class Error extends TodoState {
  final String message;

  Error({
    required this.message,
  });

  @override
  List<Object?> get props => [this.message];
}

class Loaded extends TodoState {
  final List<Todo> todos;

  Loaded({
    required this.todos,
  });

  @override
  List<Object?> get props => [this.todos];
}

 */
