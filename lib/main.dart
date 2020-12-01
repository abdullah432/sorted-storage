import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/bloc/authentication/authentication_bloc.dart';
import 'package:web/bloc/authentication/authentication_event.dart';
import 'package:web/bloc/navigation/navigation_bloc.dart';
import 'package:web/locator.dart';
import 'package:web/route.dart';
import 'package:web/theme.dart';
import 'package:web/ui/pages/static/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  AuthenticationBloc _authenticationBloc;
  NavigationBloc _navigationBloc;

  @override
  void initState() {
    super.initState();
    _navigationBloc = NavigationBloc(navigatorKey: _navigatorKey);
    _authenticationBloc = AuthenticationBloc();
    _authenticationBloc.add(AuthenticationSilentSignInEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _navigationBloc.close();
    _authenticationBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(
          create: (BuildContext context) => _navigationBloc,
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => _authenticationBloc,
        ),
      ],
      child: MaterialApp(
        title: 'Sorted Storage',
        theme: myThemeData,
        navigatorKey: _navigatorKey,
        onGenerateRoute: RouteConfiguration.onGenerateRoute,
        initialRoute: HomePage.route,
      ),
    );
  }
}