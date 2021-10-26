// import 'package:equatable/equatable.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:test_app/example/model/todo.dart';
//
// @immutable
// abstract class TodoEvent extends Equatable { }
//
//
// class ListTodosEvent extends TodoEvent {
//   @override
//   List<Object?> get props => [];
// }
//
//
// class CreateTodosEvent extends TodoEvent {
//   final String title;
//
//   CreateTodosEvent({
//     required this.title,
//   });
//
//   @override
//   List<Object?> get props => [this.title];
// }
//
//
// class DeleteTodosEvent extends TodoEvent {
//   final Todo todo;
//
//   DeleteTodosEvent({
//     required this.todo,
//   });
//
//   @override
//   List<Object?> get props => [this.todo];
// }
