import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/book.dart';
import '../../model/writer.dart';

class BookRepository implements BaseDbRepo<Book> {
  final Database database;

  BookRepository(this.database);

  @override
  Future<int> insert(Book book) async {
    // [!] ID null olarak gönderilir, SQLite otomatik artırır.
    return await database.insert('books', book.toJson(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  @override
  Future<Book?> get(int id) async {
    final List<Map<String, dynamic>> maps = await database.rawQuery(
      """
      SELECT
        b.id AS book_id,
        b.name AS book_name,
        b.numberOfPages AS book_numberOfPages,
        b.writerId AS book_writerId,
        w.id AS writer_id,
        w.name AS writer_name
      FROM books AS b
      LEFT JOIN writers AS w ON b.writerId = w.id
      WHERE b.id = ?
    """,
      [id],
    );

    if (maps.isNotEmpty) {
      final Map<String, dynamic> map = maps.first;
      final Writer? writer = map['writer_id'] != null ? Writer(id: map['writer_id'], name: map['writer_name']) : null;
      return Book(
        id: map['book_id'],
        name: map['book_name'],
        numberOfPages: map['book_numberOfPages'],
        writerId: map['book_writerId'],
        writer: writer,
      );
    }
    return null;
  }

  @override
  Future<List<Book>> getAll() async {
    final List<Map<String, dynamic>> maps = await database.rawQuery("""
      SELECT
        b.id AS book_id,
        b.name AS book_name,
        b.numberOfPages AS book_numberOfPages,
        b.writerId AS book_writerId,
        w.id AS writer_id,
        w.name AS writer_name
      FROM books AS b
      LEFT JOIN writers AS w ON b.writerId = w.id
    """);

    return List.generate(maps.length, (i) {
      final Map<String, dynamic> map = maps[i];
      final Writer? writer = map['writer_id'] != null ? Writer(id: map['writer_id'], name: map['writer_name']) : null;
      return Book(
        id: map['book_id'],
        name: map['book_name'],
        numberOfPages: map['book_numberOfPages'],
        writerId: map['book_writerId'],
        writer: writer,
      );
    });
  }

  @override
  Future<int> update(Book book) async {
    if (book.id == null) {
      throw Exception("Book ID cannot be {null} for [update] operation.");
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
