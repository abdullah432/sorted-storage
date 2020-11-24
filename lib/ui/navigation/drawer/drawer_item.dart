import 'package:flutter/material.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final Function callback;

  const DrawerItem({this.title, this.icon, this.route, this.callback});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (callback != null) {
          callback();
        } else if (route != null) {
          locator<NavigationService>().navigateTo(this.route);
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
