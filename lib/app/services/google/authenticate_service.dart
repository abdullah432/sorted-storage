import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/app/services/authenticate_service.dart';


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
        displayName: user.displayName,
        id: user.id,
        email: user.email,
        photoUrl: user.photoUrl,
        headers: user.authHeaders);
    print('current user------------');
    print(currentUser);
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

  Future<bool> signIn() async {
    try {
      bool signedIn = await _signIn();
      return signedIn;
    } catch (error) {
      print(error);
    }
  }

  Future<bool> _signIn() async {
    print('signing in');
    GoogleSignInAccount account;
    try {
      account = await _googleSignIn.signIn();
    } catch (e) {
      print('error during signing in ${e.toString()}');
    }
    if (account == null) {
      return false;
    }
    print('signed in');

    currentUser = usr.User(
        balance: 0,
        id: account.id,
        email: account.email,
        photoUrl: account.photoUrl,
        headers: account.authHeaders);

    return true;
  }

  Future<void> signOut() async {
    print('signing out');
    await _googleSignIn.signOut();
    currentUser = null;
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
