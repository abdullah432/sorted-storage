import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/locator.dart';
import 'package:web/theme.dart';
import 'package:web/ui/footer/footer.dart';
import 'package:web/ui/navigation/drawer/drawer.dart';
import 'package:web/ui/navigation/navigation_bar/navigation.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/widgets/loading.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget widget;
  final bool requiresAuthentication;
  final User user;
  final String targetRoute;
  final bool includeNavigation;

  const LayoutWrapper(
      {Key key,
      this.widget,
      this.requiresAuthentication = false,
      this.user,
      this.targetRoute,
      this.includeNavigation = true})
      : super(key: key);

  Widget content() {
    print("authentication: ${this.requiresAuthentication}");
    print("user: $user");
    print("user: $targetRoute");
    if (this.requiresAuthentication) {
      if (user != null) {
        return FutureBuilder(
            future: locator<StorageService>().initialize(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Something went wrong ${snapshot.error}'));
              }
              // Once complete, show your application
              if (snapshot.connectionState == ConnectionState.done) {
                return Content(
                    widget: widget,
                    user: user,
                    includeNavigation: includeNavigation);
              }
              return FullPageLoadingLogo();
            });
      }
      return Content(
          widget: LoginPage(targetRoute: targetRoute),
          user: user,
          includeNavigation: includeNavigation);
    } else {
      return Content(
          widget: widget, user: user, includeNavigation: includeNavigation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(user: this.user),
      body: content(),
    );
  }
}

class Content extends StatelessWidget {
  const Content({
    Key key,
    @required this.widget,
    this.user,
    this.includeNavigation = true,
  }) : super(key: key);

  final Widget widget;
  final User user;
  final bool includeNavigation;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) => Container(
        width: sizingInformation.screenSize.width,
        height: sizingInformation.screenSize.height,
        decoration: myBackgroundDecoration,

        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
              child: Column(
              children: [
                includeNavigation ? NavigationBar(user: user) : Container(),
                widget,
                Footer(width: sizingInformation.screenSize.width)
              ],),

        ),
      ),
    );
  }
}
