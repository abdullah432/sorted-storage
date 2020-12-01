import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/bloc/authentication/authentication_bloc.dart';
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
  final String targetRoute;
  final bool includeNavigation;

  const LayoutWrapper(
      {Key key,
      this.widget,
      this.requiresAuthentication = false,
      this.targetRoute,
      this.includeNavigation = true})
      : super(key: key);

  Widget content() {
    if (this.requiresAuthentication) {
      return BlocBuilder<AuthenticationBloc, User>(builder: (context, user) {
        return Scaffold(
            drawer: NavigationDrawer(user: user),
            body: FutureBuilder(
              future: locator<StorageService>().initialize(user),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Something went wrong ${snapshot.error}'));
                }
                // Once complete, show your application
                if (snapshot.connectionState == ConnectionState.done) {
                  if (user != null) {
                    return Content(
                        widget: widget,
                        user: user,
                        includeNavigation: includeNavigation);
                  }

                  return Content(
                      widget: LoginPage(targetRoute: targetRoute),
                      user: user,
                      includeNavigation: includeNavigation);
                }
                return FullPageLoadingLogo();
              },
            ));
      });
    } else {
      return Scaffold(
          drawer: NavigationDrawer(user: null),
          body: FutureBuilder(
            future: locator<StorageService>().initialize(null),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Something went wrong ${snapshot.error}'));
              }
              // Once complete, show your application
              if (snapshot.connectionState == ConnectionState.done) {
                return Content(
                    widget: widget,
                    user: null,
                    includeNavigation: includeNavigation);
              }
              return FullPageLoadingLogo();
            },
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return content();
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
            ],
          ),
        ),
      ),
    );
  }
}
