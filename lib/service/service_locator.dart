import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/database/db_service.dart';
import 'package:where_is_library/core/preferences/secure_storage_manager.dart';
import 'package:where_is_library/core/preferences/shared_preferences_manager.dart';
import 'package:where_is_library/core/repository/book_repository.dart';
import 'package:where_is_library/core/repository/library_repository.dart';
import 'package:where_is_library/core/repository/library_location_repository.dart';
import 'package:where_is_library/core/repository/number_of_book_repository.dart';
import 'package:where_is_library/core/repository/writer_repository.dart';

Future<void> serviceLocator() async {
  // -->  Secure Storage Manager
  final secureStorage = SecureStorageManager(const FlutterSecureStorage());
  GetIt.I.registerSingleton<SecureStorageManager>(secureStorage);

  // --> Shared Preferences Manager
  final prefs = await SharedPreferences.getInstance();
  final sharedPreferencesManager = SharedPreferencesManager(
    prefs,
    isUserLoggedIn: () async => false, // İleride kullanıcı login durumu için
  );
  GetIt.I.registerSingleton<SharedPreferencesManager>(sharedPreferencesManager);

  // -->  Database Service
  final dbService = DBService();
  GetIt.I.registerSingleton<DBService>(dbService);

  // -->  Database instance'ını lazy singleton olarak kaydet
  GetIt.I.registerLazySingletonAsync<Database>(() async {
    return await dbService.database;
  });

  // -->  Repository'leri lazy singleton olarak kaydet (Database'e bağımlı)
  GetIt.I.registerLazySingletonAsync<WriterRepository>(() async {
    final database = await GetIt.I.getAsync<Database>();
    return WriterRepository(database);
  });

  GetIt.I.registerLazySingletonAsync<BookRepository>(() async {
    final database = await GetIt.I.getAsync<Database>();
    return BookRepository(database);
  });

  GetIt.I.registerLazySingletonAsync<LibraryRepository>(() async {
    final database = await GetIt.I.getAsync<Database>();
    return LibraryRepository(database);
  });

  GetIt.I.registerLazySingletonAsync<LibraryLocationRepository>(() async {
    final database = await GetIt.I.getAsync<Database>();
    return LibraryLocationRepository(database);
  });

  GetIt.I.registerLazySingletonAsync<NumberOfBookRepository>(() async {
    final database = await GetIt.I.getAsync<Database>();
    return NumberOfBookRepository(database);
  });

  // -->
  await GetIt.I.allReady();
}
