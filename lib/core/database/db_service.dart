import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:where_is_library/model/book.dart';
import 'package:where_is_library/model/library.dart';
import 'package:where_is_library/model/library_location.dart';
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
      version: 4,
      onCreate: (db, version) async {
        // [?] Buraya her seferinde model eklendiginde ekleme mi yapilacak ???
        await db.execute(Writer.createTable);
        await db.execute(Book.createTable);
        await db.execute(LibraryLocation.createTable);
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
        if (oldVersion < 4) {
          // --> Version 4'te library_locations tablosu eklendi ve libraries tablosu güncellendi
          await db.execute(LibraryLocation.createTable);
          // Mevcut libraries tablosunu yedekle
          await db.execute('ALTER TABLE libraries RENAME TO libraries_backup');
          // Yeni libraries tablosunu oluştur
          await db.execute(Library.createTable);
          // Veriyi taşı (location string'ini varsayılan bir LibraryLocation olarak oluştur)
          // Bu kısımda mevcut location string verilerini LibraryLocation'a taşımak gerekiyor
          // Basitlik için önce default location oluşturalım
          await db.execute(
            "INSERT INTO library_locations (title, lat, long) VALUES ('Bilinmeyen Konum', 0, 0)",
          );
          // Eski verileri yeni yapıya taşı
          await db.execute("""
            INSERT INTO libraries (id, name, locationId)
            SELECT id, name, 1 FROM libraries_backup
          """);
          // Yedek tabloyu sil
          await db.execute('DROP TABLE libraries_backup');
        }
      },
    );
  }
}
