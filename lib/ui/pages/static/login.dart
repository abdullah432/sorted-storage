import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/pages/dynamic/media.dart';

class LoginPage extends StatelessWidget {
  static const route = '/login';
  final String targetRoute;

  const LoginPage({Key key, this.targetRoute = MediaPage.route}) : super(key: key);

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Please sign in", style: myThemeData.textTheme.headline3),
              SizedBox(height: 7.0),
              Container(width: 100,child: Divider(thickness: 1)),
              SizedBox(height: 7.0),
              GoogleSignInButton(
                onPressed: () async {
                  BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationSignInEvent());
//                  bool signedIn =
//
//                  await locator<AuthenticationService>().signIn();
//                  if (signedIn) {
//                    BlocProvider.of<NavigationBloc>(context).add(NavigateToMediaEvent());
//                  }
                },
                darkMode: false, // default: false
              ),
            ],
          ),
        ),
      ),
    );
  }
}
