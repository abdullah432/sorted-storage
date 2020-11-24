import 'package:web/app/models/user.dart';


abstract class AuthenticationService {
  User getCurrentUser();
  Future<Map<String, String>> getAuthHeaders();
  Future<void> signIn(String destinationRoute);
  Future<void> signOut();
  Future silentSignIn();
  Stream onUserChange();
}

