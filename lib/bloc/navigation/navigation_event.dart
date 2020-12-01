// this import is needed to import NavItem,
// which we'll use to represent the item the user has selected
// it's important to use an abstract class, even if you have one
// event, so that you can use it later in your BLoC and or tests
abstract class NavigationEvent {
  final String route;
  final bool requiresAuthentication;
  const NavigationEvent({this.route = "", this.requiresAuthentication = false});
}

class NavigatorPopEvent extends NavigationEvent{
}

class NavigateToHomeEvent extends NavigationEvent{
  NavigateToHomeEvent() : super(route: "/home");
}

class NavigateToLoginEvent extends NavigationEvent{
  NavigateToLoginEvent() : super(route: "/login");
}

class NavigateToMediaEvent extends NavigationEvent{
  NavigateToMediaEvent() : super(route: "/media", requiresAuthentication: true);
}

class NavigateToDocumentsEvent extends NavigationEvent{
  NavigateToDocumentsEvent() : super(route: "/documents", requiresAuthentication: true);
}

class NavigateToTermsEvent extends NavigationEvent{
  NavigateToTermsEvent() : super(route: "/terms-of-conditions");
}

class NavigateToPrivacyEvent extends NavigationEvent{
  NavigateToPrivacyEvent() : super(route: "/privacy-policy");
}