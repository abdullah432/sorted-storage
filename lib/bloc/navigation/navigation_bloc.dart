import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:web/bloc/navigation/navigation_event.dart';

class NavigationBloc extends Bloc<NavigationEvent, dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationBloc({this.navigatorKey}) : super(0);

  @override
  Stream<dynamic> mapEventToState(NavigationEvent event) async* {
    switch (event.runtimeType) {
      case NavigatorPopEvent:
        navigatorKey.currentState.pop();
        break;
      default:
        navigatorKey.currentState.pushNamed(event.route);
        break;
    }
  }
}