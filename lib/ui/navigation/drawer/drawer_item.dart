import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/bloc/authentication/authentication_bloc.dart';
import 'package:web/bloc/authentication/authentication_event.dart';
import 'package:web/bloc/navigation/navigation_bloc.dart';
import 'package:web/bloc/navigation/navigation_event.dart';
import 'package:web/locator.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final NavigationEvent event;

  const DrawerItem({this.title, this.icon, this.event});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        if (event is NavigateToLoginEvent) {
          BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationSignOutEvent());
        }else {
          BlocProvider.of<NavigationBloc>(context).add(event);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 30, top: 30, bottom: 30),
        child: Row(
          children: <Widget>[
            Icon(icon),
            SizedBox(width: 30),
            Text(
              title,
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
    );
  }
}
