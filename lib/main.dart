import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/route.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  DriveBloc _driveBloc;

  @override
  void initState() {
    super.initState();
    _driveBloc = DriveBloc();
    _navigationBloc = NavigationBloc(navigatorKey: _navigatorKey);
    _authenticationBloc = AuthenticationBloc();
    _authenticationBloc.add(AuthenticationSilentSignInEvent());
  }

  @override
  void dispose() {
    //_driveBloc.
    super.dispose();
    _navigationBloc.close();
    _authenticationBloc.close();
    _driveBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DriveBloc>(
          create: (BuildContext context) => _driveBloc,
        ),
        BlocProvider<NavigationBloc>(
          create: (BuildContext context) => _navigationBloc,
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => _authenticationBloc,
        ),
        BlocProvider<TimelineBloc>(
        create: (BuildContext context) => TimelineBloc(),
        )
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
