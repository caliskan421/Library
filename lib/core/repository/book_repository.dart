import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/book.dart';

class BookRepository implements BaseDbRepo<Book> {
  final Database database;

  BookRepository(this.database);

  @override
  Future<int> insert(Book book) async {
    // [!] ID null olarak gönderilir, SQLite otomatik artırır.
    return await database.insert('books', book.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<Book?> get(int id) async {
    final List<Map<String, dynamic>> maps = await database.query('books', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Book.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<List<Book>> getAll() async {
    final List<Map<String, dynamic>> maps = await database.query('books');
    return List.generate(maps.length, (i) {
      return Book.fromJson(maps[i]);
    });
  }

  @override
  Future<int> update(Book book) async {
    if (book.id == null) {
      throw Exception("Book ID cannot be null for update operation.");
    }
    return await database.update('books', book.toJson(), where: 'id = ?', whereArgs: [book.id]);
  }

  @override
  Future<void> delete(int id) async {
    await database.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAll() async {
    await database.delete('books');
  }
}
