import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';
import 'package:web/theme.dart';
import 'package:web/ui/pages/dynamic/profile.dart';
import 'package:web/ui/widgets/avatar.dart';

class AvatarWithMenu extends StatelessWidget {
  final User user;
  AvatarWithMenu({
    Key key, this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    void _showPopupMenu() async {
      await showMenu(
        useRootNavigator: true,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
        context: locator<NavigationService>().context,
        position: RelativeRect.fromLTRB(double.maxFinite, 120, 24, 0),
        items: [
          PopupMenuItem(
            enabled: false,
            child: Column(
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Balance:"),
                      Text("\$${user.balance}"),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            hoverElevation: 1.0,
                            shape: CircleBorder(),
                            onPressed: () {},
                            child: Avatar(url: user.photoUrl, size: 100.0),
                          ),
                          SizedBox(height: 10),
                          Text(user.email.toLowerCase().substring(0, user.email.length > 30 ? 30 : user.email.length),
                          style: myThemeData.textTheme.caption),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            enabled: false,
            child: Divider(),
          ),
          PopupMenuItem(
            enabled: false,
            child: Center(
              child: MaterialButton(
                minWidth: 190,
                onPressed: () {
                  locator<NavigationService>().navigateTo(AccountPage.route);
                },
                child: Text("Profile"),
              ),
            ),
          ),
          PopupMenuItem(
            enabled: false,
            child: Center(
              child: MaterialButton(
                minWidth: 190,
                onPressed: () {},
                child: Text("Support"),
              ),
            ),
          ),
          PopupMenuItem(
            enabled: false,
            child: Center(
              child: MaterialButton(
                minWidth: 190,
                onPressed: () {
                  locator<AuthenticationService>().signOut();
                },
                child: Text("Logout"),
              ),
            ),
          ),
        ],
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Avatar(url: user.photoUrl, size: 45.0),
        onTap: () {
          _showPopupMenu();
        },
      ),
    );
  }
}