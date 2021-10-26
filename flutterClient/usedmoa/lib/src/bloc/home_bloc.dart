import 'package:bloc/bloc.dart';
import 'package:usedmoa/src/bloc/home_event.dart';
import 'package:usedmoa/src/bloc/home_state.dart';
import 'package:usedmoa/src/model/home.dart';
import 'package:usedmoa/src/repository/home_repository.dart';

// bloc에서는 전체적인 bloc등을 생성해준다.?
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({
    this.repository,
  }) : super(Empty());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is ListHomesEvent) {
      yield* _mapListHomesEvent(event);
    }
  }

  Stream<HomeState> _mapListHomesEvent(ListHomesEvent event) async* {
    try {
      yield Loading();

      final resp = await this.repository.listHome();

      final homes = resp.map<Home>((e) => Home.fromJson(e)).toList();

      yield Loaded(homes: homes);
    } catch (e) {
      yield Error(message: e.toString());
    }
  }
}
