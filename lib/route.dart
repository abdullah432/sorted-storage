import 'package:flutter/material.dart';
import 'package:web/app/extensions/string_extensions.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/locator.dart';
import 'package:web/ui/pages/dynamic/documents.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/dynamic/profile.dart';
import 'package:web/ui/pages/dynamic/view.dart';
import 'package:web/ui/pages/static/donate.dart';
import 'package:web/ui/pages/static/error.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/pages/static/login.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';
import 'package:web/wrappers.dart';

class RouteConfiguration {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    var routingData = settings.name.getRoutingData;

    if (routingData.route.startsWith(ViewPage.route)) {
      return _getPageRoute(
          LayoutWrapper(
              user: User(),
              widget: ViewPage(path: routingData.route),
              includeNavigation: false,
              requiresAuthentication: true),
          settings.name);
    }

    User user = locator<AuthenticationService>().getCurrentUser();
    Widget widget;
    String targetRoute = routingData.route;
    bool requiresAuthentication = false;
    switch (routingData.route) {
      case LoginPage.route:
        requiresAuthentication = true;
        targetRoute = LoginPage.route;
        widget = MediaPage();
        break;
      case MediaPage.route:
        requiresAuthentication = true;
        widget = MediaPage();
        break;
      case DocumentsPage.route:
        requiresAuthentication = true;
        widget = DocumentsPage();
        break;
      case AccountPage.route:
        requiresAuthentication = true;
        widget = AccountPage();
        break;
      case PolicyPage.route:
        widget = PolicyPage();
        break;
      case TermsPage.route:
        widget = TermsPage();
        break;
      case ErrorPage.route:
        widget = ErrorPage();
        break;
      case DonatePage.route:
        widget = DonatePage();
        break;
      default:
        widget = HomePage();
        break;
    }

    return _getPageRoute(
        LayoutWrapper(
            user: user,
            widget: widget,
            requiresAuthentication: requiresAuthentication,
            targetRoute: targetRoute),
        settings.name);
  }
}

PageRoute _getPageRoute(Widget child, String routeName) {
  return _FadeRoute(child: child, routeName: routeName);
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;

  _FadeRoute({this.child, this.routeName})
      : super(
            settings: RouteSettings(name: routeName),
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                child,
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) =>
                FadeTransition(
                  opacity: animation,
                  child: child,
                ));
}
