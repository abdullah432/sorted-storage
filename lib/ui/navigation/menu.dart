import 'package:flutter/material.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';
import 'package:web/theme.dart';
import 'package:web/ui/pages/dynamic/documents.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/dynamic/profile.dart';
import 'package:web/ui/pages/static/donate.dart';
import 'package:web/ui/pages/static/home.dart';

class MenuItem {
  String name;
  String route;
  IconData icon;
  Function callback;

  MenuItem({this.name, this.route, this.icon, this.callback});
}

class Menu {
  static List<MenuItem> commonItems() => [
    MenuItem(name: "Home", route: HomePage.route, icon: Icons.home),
    MenuItem(name: "Donate", route: DonatePage.route, icon: Icons.money)
  ];

  static List<MenuItem> dashboardItems() => [
    MenuItem(name: "Media", route: MediaPage.route, icon: Icons.image),
    MenuItem(name: "Documents", route: DocumentsPage.route, icon: Icons.folder),
  ];

  static List<MenuItem> loggedInItems() => [
    MenuItem(name: "Profile",   route: AccountPage.route, icon: Icons.account_circle),
    MenuItem(name: "Logout", callback: () => locator<AuthenticationService>().signOut(), icon: Icons.exit_to_app),
  ];
}


List<Widget> createMenu(BuildContext context, bool loggedIn, bool text) {
  List<Widget> widgets = [];

  if (loggedIn) {
    for (MenuItem menuItem in Menu.dashboardItems()) {
      widgets.add(MaterialButton(
        child: text ? Row(
          children: [
            Icon(menuItem.icon),
            SizedBox(width: 10),
            Text(
              menuItem.name,
              style: myThemeData.textTheme.headline6,
            ),
          ],
        ) : Icon(menuItem.icon),
        onPressed: () {
          locator<NavigationService>().navigateTo(menuItem.route);
        },
      ));
    }
  } else {
    for (MenuItem menuItem in Menu.commonItems()) {
      widgets.add(MaterialButton(
        onPressed: () {
          locator<NavigationService>().navigateTo(menuItem.route);
        },
        child: Text(
          menuItem.name,
          style: myThemeData.textTheme.headline6,
        ),
      ));
    }
  }

  return widgets;
}



