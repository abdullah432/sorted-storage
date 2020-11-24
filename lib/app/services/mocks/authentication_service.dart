import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/static/login.dart';

class MockAuthenticationService implements AuthenticationService{
  usr.User currentUser;

  Future<Map<String, String>> getAuthHeaders() async {
    return null;
  }

  Future<void> signIn(String destinationRoute) async {
    try {
      currentUser = usr.User(
          balance: 0,
          id: "1",
          email: "joris@sup.nz",
          photoUrl: "assets/images/logo.png",
          headers: null);

      if (destinationRoute != null) {
        locator<NavigationService>().navigateTo(destinationRoute);
      } else {
        locator<NavigationService>().navigateTo(MediaPage.route);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> signOut() async {
    currentUser = null;
    locator<NavigationService>().navigateTo(LoginPage.route);
    print('signed out');
  }

  Future<GoogleSignInAccount> silentSignIn() async {
    return null;
  }

  Stream onUserChange() {
    StreamController<GoogleSignInAccount> streamController = new StreamController();
    return streamController.stream;
  }

  @override
  usr.User getCurrentUser() {
    return currentUser;
  }
}
