import 'package:web/app/models/user.dart';


abstract class AuthenticationService {
  User getCurrentUser();
  Future<Map<String, String>> getAuthHeaders();
  Future<bool> signIn();
  Future<void> signOut();
  Future silentSignIn();
  Stream onUserChange();
}

