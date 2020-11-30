import 'package:get_it/get_it.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/google/authenticate_service.dart';
import 'package:web/app/services/google/storage_service.dart';
import 'package:web/app/services/mocks/authentication_service.dart';
import 'package:web/app/services/mocks/storage_service.dart';
import 'package:web/app/services/storage_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  bool mockData = false;

  AuthenticationService authenticationService;
  StorageService storageService;

  if (mockData) {
    authenticationService = MockAuthenticationService();
    storageService = MockStorageService();
  } else {
    authenticationService = GoogleAuthenticationService();
    storageService = GoogleStorageService();
  }

  locator.registerLazySingleton(() => authenticationService);
  locator.registerLazySingleton(() => storageService);
  locator.registerLazySingleton(() => DialogService());
}
