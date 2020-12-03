import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class AuthenticationSignInEvent extends AuthenticationEvent {}

class AuthenticationSignOutEvent extends AuthenticationEvent {}

class AuthenticationSilentSignInEvent extends AuthenticationEvent {}

class AuthenticationNewUserEvent extends AuthenticationEvent {
  final GoogleSignInAccount user;

  AuthenticationNewUserEvent(this.user);
}
