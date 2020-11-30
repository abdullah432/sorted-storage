import 'package:get_it/get_it.dart';
import 'package:web/app/services/google/storage_service.dart';
import 'package:web/app/services/mocks/storage_service.dart';
import 'package:web/app/services/storage_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  bool mockData = false;

  StorageService storageService;

  if (mockData) {
    storageService = MockStorageService();
  } else {
    storageService = GoogleStorageService();
  }

  locator.registerLazySingleton(() => storageService);
}
