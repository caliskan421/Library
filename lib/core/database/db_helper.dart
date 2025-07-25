import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:where_is_library/model/book.dart';
import 'package:where_is_library/model/library.dart';
import 'package:where_is_library/model/number_of_book.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'where_is_library.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(Book.createTable);
        await db.execute(Library.createTable);
        await db.execute(NumberOfBook.createTable);
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Migrasyon işlemleri burada yapılır
      },
    );
  }
}
