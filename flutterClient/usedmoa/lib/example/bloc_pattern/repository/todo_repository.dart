// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:test_app/example/model/todo.dart';
//
// /// GET - ListTodo
// /// POST - CreateTodo
// /// DELETE -DeleteTodo
// class TodoRepository{
//
//   Future<List<Map<String, dynamic>>> listTodo() async {
//     await Future.delayed((Duration(seconds: 1)));
//
//     return [
//       {
//         'id' : 1,
//         'title' : 'test',
//         'createdAt': DateTime.now().toString(),
//       },
//       {
//         'id' : 2,
//         'title' : 'test2',
//         'createdAt': DateTime.now().toString(),
//       },
//     ];
//   }
//
//
//   Future<Map<String, dynamic>> createTodo(Todo todo) async{
//
//     // body -> request -> respose -> return
//     await Future.delayed((Duration(seconds: 1)));
//
//     return todo.toJson();
//   }
//
//
//   Future<Map<String, dynamic>> deleteTodo(Todo todo) async{
//     await Future.delayed((Duration(seconds: 1)));
//
//     return todo.toJson();
//   }
// }
