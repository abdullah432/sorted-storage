import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';
import 'package:web/ui/pages/dynamic/media.dart';
import 'package:web/ui/pages/static/login.dart';


class GoogleAuthenticationService implements AuthenticationService {
  usr.User currentUser;
  StreamController newUserStream = BehaviorSubject();

  final _googleSignIn = new GoogleSignIn(
    scopes: [
      DriveApi.DriveScope,
    ],
  );


  void _setCurrentUser(GoogleSignInAccount user) {
    if (user == null) {
      return;
    }
    currentUser = usr.User(
        balance: 0,
        id: user.id,
        email: user.email,
        photoUrl: user.photoUrl,
        headers: user.authHeaders);
  }

  usr.User getCurrentUser() {
    return currentUser;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    print(_googleSignIn.currentUser);
    if (_googleSignIn.currentUser == null) {
      return null;
    }
    return await _googleSignIn.currentUser.authHeaders;
  }

  Future<void> signIn(String destinationRoute) async {
    try {
      print('signing in');
      GoogleSignInAccount account = await _googleSignIn.signIn();
      if (account == null) {
        return;
      }
      print('signed in');

      currentUser = usr.User(
          balance: 0,
          id: account.id,
          email: account.email,
          photoUrl: account.photoUrl,
          headers: account.authHeaders);

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
    print('signing out');
    await _googleSignIn.signOut();
    currentUser = null;
    locator<NavigationService>().navigateTo(LoginPage.route);
    print('signed out');
  }

  Future silentSignIn() async {
    _setCurrentUser(await _googleSignIn.signInSilently());
  }

  Stream onUserChange() {
    _googleSignIn.onCurrentUserChanged.listen((event) {
      _setCurrentUser(event);
      newUserStream.add(true);
    });

    return newUserStream.stream;
  }

}
