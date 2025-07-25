import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:where_is_library/core/preferences/secure_storage_manager.dart';

Future<void> serviceLocator() async {
  final secureStorage = SecureStorageManager(const FlutterSecureStorage());

  GetIt.I.registerSingleton<SecureStorageManager>(secureStorage);
}
