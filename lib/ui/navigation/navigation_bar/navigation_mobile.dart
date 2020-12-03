import 'package:flutter/material.dart';
import 'package:web/app/models/user.dart';
import 'package:web/ui/navigation/menu.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_login.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';

import 'navigation_tablet.dart';

class NavigationBarMobile extends StatelessWidget {
  final User user;

  const NavigationBarMobile({Key key,  this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> content;
    if (user != null) {
      content = [
        NavigationMenu(),
        Container(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: createMenu(context, true, true),
        ),
        Container()
      ];
    } else {
      content = [
        Row(
          children: [
            NavigationMenu(),
            NavBarLogo(showText: false)
          ],
        ),
        NavigationLogin(loggedIn: false)
      ];
    }

    return NavigationContent(children: content);
  }
}

