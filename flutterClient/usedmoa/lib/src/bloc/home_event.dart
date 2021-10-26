import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';


// event에서는 bloc에 추가?생성?할 이벤트를 등록할 수 있게 정의해준다.
@immutable
abstract class HomeEvent extends Equatable {}

class ListHomesEvent extends HomeEvent {
  @override
  List<Object> get props => [];
}
