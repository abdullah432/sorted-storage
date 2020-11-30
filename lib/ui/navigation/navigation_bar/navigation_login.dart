import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/bloc/navigation/navigation_bloc.dart';
import 'package:web/bloc/navigation/navigation_event.dart';
import 'package:web/locator.dart';

class NavigationLogin extends StatelessWidget {
  final bool loggedIn;

  const NavigationLogin({Key key, @required this.loggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (loggedIn) {
          // this will cause a automatic navigation
          locator<AuthenticationService>().signOut();
        } else {
          BlocProvider.of<NavigationBloc>(context).add(NavigateToLoginEvent());
        }
      },
      child: Text(
        loggedIn ? 'Logout' : 'Login',
        style: Theme.of(context).textTheme.button,
      ),
      color: Theme.of(context).primaryColorDark,
    );
  }
}
