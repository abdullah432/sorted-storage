import 'dart:html' as html;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

class NavigationBloc extends Bloc<NavigationEvent, dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationBloc({this.navigatorKey}) : super(0);

  @override
  Stream<dynamic> mapEventToState(NavigationEvent event) async* {
    switch (event.runtimeType) {
      case NavigatorPopEvent:
        navigatorKey.currentState.pop();
        break;
      case NavigateToChangeProfileEvent:
        html.window.open("https://myaccount.google.com/personal-info", 'Account');
        break;
      case NavigateToUpgradeEvent:
        html.window.open("https://one.google.com/about/plans", 'Upgrade');
        break;
      default:
        navigatorKey.currentState.pushNamed(event.route);
        break;
    }
  }
}