import 'package:bloc/bloc.dart';

//import 'package:test_app/src/bloc/todo_event.dart';
//import 'package:test_app/src/bloc/todo_state.dart';
//import 'package:test_app/example/model/todo.dart';
//import 'package:test_app/example/repository/todo_repository.dart';

/*
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;

  TodoBloc({
    required this.repository,
  }) : super(Empty());

  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    if(event is ListTodosEvent) {
      yield* _mapListTodosEvent(event);
    } else if(event is CreateTodosEvent) {
      yield* _mapCreateTodosEvent(event);
    } else if(event is DeleteTodosEvent) {
      yield* _mapDeleteTodosEvent(event);
    }
  }

  Stream<TodoState> _mapListTodosEvent(ListTodosEvent event) async* {
    try {
      yield Loading();

      final resp = await this.repository.listTodo();

      final todos = resp.map<Todo>((e) => Todo.fromJson(e)).toList();

      yield Loaded(todos: todos);
    } catch(e) {
      yield Error(message: e.toString());
    }
  }

  Stream<TodoState> _mapCreateTodosEvent(CreateTodosEvent event) async* {
    try {
      if(state is Loaded) {
        final parsedState = state as Loaded;

        final newTodo = Todo(
          id: parsedState.todos[parsedState.todos.length -1].id + 1,
          title: event.title,
          createdAt: DateTime.now().toString(),
        );

        final prevTodos = [...parsedState.todos,];

        final newTodos = [
          ...prevTodos,
          newTodo,
        ];

        yield Loaded(todos: newTodos);

        final resp = await this.repository.createTodo(newTodo);

        yield Loaded(
          todos: [
          ...prevTodos,
          Todo.fromJson(resp),
          ],
        );
      }
    } catch(e) {
      yield Error(message: e.toString());
    }
  }

  Stream<TodoState> _mapDeleteTodosEvent(DeleteTodosEvent event) async* {
    try {
      if(state is Loaded) {
        final newTodos = (state as Loaded)
            .todos
            .where((todo) => todo.id != event.todo.id)
            .toList();  
        
        yield Loaded(todos: newTodos);

        await repository.deleteTodo(event.todo);
      }
    } catch(e) {
      yield Error(message: e.toString());
    }
  }
}

 */
