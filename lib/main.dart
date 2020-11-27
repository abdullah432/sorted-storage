
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';
import 'package:web/route.dart';
import 'package:web/theme.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/widgets/loading.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  
  @override
  void initState() {
    super.initState();

    // TODO move to own service to remove duplicate code
    _waitUntil(() => locator<NavigationService>().context != null, Duration(milliseconds: 100)).then((value) => locator<DialogService>().cookieDialog());
  }

  Future _waitUntil(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (test()) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locator<AuthenticationService>().silentSignIn(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
              stream: locator<AuthenticationService>().onUserChange(),
              builder: (context, snapshot) {
                return MaterialApp(
                  theme: myThemeData,
                  title: 'Sorted Storage',
                  navigatorKey: locator<NavigationService>().navigatorKey,
                  onGenerateRoute: RouteConfiguration.onGenerateRoute,
                  initialRoute: HomePage.route,
                );
              });
        }

        return FullPageLoadingLogo();
      },
    );
  }
}

