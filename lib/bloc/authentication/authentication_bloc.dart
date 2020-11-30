import 'package:bloc/bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/bloc/authentication/authentication_event.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, usr.User> {
  final _googleSignIn = new GoogleSignIn(
    scopes: [
      DriveApi.DriveScope,
    ],
  );

  AuthenticationBloc() : super(null) {
    _googleSignIn.onCurrentUserChanged.listen((user) {
      this.add(AuthenticationNewUserEvent(user));
    });
  }

  @override
  Stream<usr.User> mapEventToState(AuthenticationEvent event) async* {
      switch (event.runtimeType) {
        case AuthenticationSignInEvent:
          _googleSignIn.signIn();
          break;
        case AuthenticationSilentSignInEvent:
          _googleSignIn.signInSilently();
          break;
        case AuthenticationSignOutEvent:
          _googleSignIn.signOut();
          break;
        case AuthenticationNewUserEvent:
          yield await getCurrentUser((event as AuthenticationNewUserEvent).user);
          break;
      }
  }

  Future<usr.User> getCurrentUser(GoogleSignInAccount user) async {
    if (user == null) {
      return null;
    }
    return usr.User(
        balance: 0,
        displayName: user.displayName,
        id: user.id,
        email: user.email,
        photoUrl: user.photoUrl,
        headers: await user.authHeaders);
  }
}
