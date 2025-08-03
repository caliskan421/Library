import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:where_is_library/model/book.dart';
import 'package:where_is_library/model/library.dart';
import 'package:where_is_library/model/number_of_book.dart';
import 'package:where_is_library/model/writer.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  static Database? _database;

  factory DBService() {
    return _instance;
  }

  DBService._internal();

  // [?] Neden {get} medou; nasil calisir; neden tercih edilmis ???
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
      version: 3,
      onCreate: (db, version) async {
        // [?] Buraya her seferinde model eklendiginde ekleme mi yapilacak ???
        await db.execute(Writer.createTable);
        await db.execute(Book.createTable);
        await db.execute(Library.createTable);
        await db.execute(NumberOfBook.createTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // --> Version 2'de writers tablosu eklendi
          await db.execute(Writer.createTable);
        }
        if (oldVersion < 3) {
          // --> Version 3'te books tablosuna writerId kolonu eklendi
          await db.execute('ALTER TABLE books ADD COLUMN writerId INTEGER');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_books_writerId ON books(writerId)',
          );
        }
      },
    );
  }
}
