import 'package:flutter/material.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';
import 'package:web/ui/pages/static/login.dart';

class NavigationLogin extends StatelessWidget {
  final bool loggedIn;

  const NavigationLogin({Key key, @required this.loggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = "";
    Function method;

    if (loggedIn) {
      text = 'Logout';
      method = () {
        locator<NavigationService>().navigateTo(LoginPage.route);
        locator<AuthenticationService>().signOut();
      };
    } else {
      text = 'Login';
      method = () {
        locator<NavigationService>().navigateTo(LoginPage.route);
      };
    }
    return MaterialButton(
      onPressed: method,
      child: Text(
        text,
        style: Theme.of(context).textTheme.button,
      ),
      color: Theme.of(context).primaryColorDark,
    );
  }
}
