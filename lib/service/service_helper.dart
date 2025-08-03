import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../core/database/db_service.dart';
import '../core/preferences/secure_storage_manager.dart';
import '../core/preferences/shared_preferences_manager.dart';
import '../core/repository/book_repository.dart';
import '../core/repository/library_repository.dart';
import '../core/repository/library_location_repository.dart';
import '../core/repository/number_of_book_repository.dart';
import '../core/repository/writer_repository.dart';

// -->  Service Locator Helper - Kolay erişim için {yardımcı sınıf}
class ServiceHelper {
  static GetIt get locator => GetIt.I;

  // -->  Sync Servisler
  static SecureStorageManager get secureStorage =>
      locator<SecureStorageManager>();
  static SharedPreferencesManager get sharedPrefs =>
      locator<SharedPreferencesManager>();
  static DBService get dbService => locator<DBService>();

  // -->  Async Servisler
  static Future<BookRepository> get bookRepository =>
      locator.getAsync<BookRepository>();
  static Future<LibraryRepository> get libraryRepository =>
      locator.getAsync<LibraryRepository>();
  static Future<LibraryLocationRepository> get libraryLocationRepository =>
      locator.getAsync<LibraryLocationRepository>();
  static Future<NumberOfBookRepository> get numberOfBookRepository =>
      locator.getAsync<NumberOfBookRepository>();
  static Future<WriterRepository> get writerRepository =>
      locator.getAsync<WriterRepository>();
  static Future<Database> get database => locator.getAsync<Database>();

  // -->  Servis durumu kontrolü
  static bool get isReady => locator.isRegistered<SecureStorageManager>();
}
