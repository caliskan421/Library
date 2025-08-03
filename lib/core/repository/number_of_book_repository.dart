import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/number_of_book.dart';
import '../../model/writer.dart'; // Writer modelini import et

class NumberOfBookRepository implements BaseDbRepo<NumberOfBook> {
  final Database database;

  NumberOfBookRepository(this.database);

  @override
  Future<int> insert(NumberOfBook numberOfBook) async {
    if (numberOfBook.book.id == null) {
      throw Exception("Book ID must be set for NumberOfBook before inserting.");
    }
    if (numberOfBook.libraryId == null) {
      throw Exception("Library ID must be set for NumberOfBook before inserting.");
    }

    return await database.insert('numberOfBooks', numberOfBook.toJson(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  @override
  Future<NumberOfBook?> get(int id) async {
    final List<Map<String, dynamic>> maps = await database.rawQuery(
      """
      SELECT
        nb.id AS numberOfBook_id,
        nb.number AS numberOfBook_number,
        nb.libraryId AS libraryId,
        b.id AS book_id,
        b.name AS book_name,
        b.numberOfPages AS book_numberOfPages,
        b.writerId AS book_writerId,
        w.id AS writer_id,
        w.name AS writer_name
      FROM numberOfBooks AS nb
      JOIN books AS b ON nb.bookId = b.id
      LEFT JOIN writers AS w ON b.writerId = w.id -- Yeni JOIN
      WHERE nb.id = ?
    """,
      [id],
    );

    if (maps.isNotEmpty) {
      return NumberOfBook.fromJsonWithBook(maps.first);
    }
    return null;
  }

  @override
  Future<List<NumberOfBook>> getAll() async {
    final List<Map<String, dynamic>> maps = await database.rawQuery("""
      SELECT
        nb.id AS numberOfBook_id,
        nb.number AS numberOfBook_number,
        nb.libraryId AS libraryId,
        b.id AS book_id,
        b.name AS book_name,
        b.numberOfPages AS book_numberOfPages,
        b.writerId AS book_writerId,
        w.id AS writer_id,
        w.name AS writer_name
      FROM numberOfBooks AS nb
      JOIN books AS b ON nb.bookId = b.id
      LEFT JOIN writers AS w ON b.writerId = w.id -- Yeni JOIN
    """);

    return List.generate(maps.length, (i) {
      return NumberOfBook.fromJsonWithBook(maps[i]);
    });
  }

  @override
  Future<int> update(NumberOfBook numberOfBook) async {
    if (numberOfBook.id == null) {
      throw Exception("NumberOfBook ID cannot be {null} for [update] operation.");
    }
    return await database.update('numberOfBooks', numberOfBook.toJson(), where: 'id = ?', whereArgs: [numberOfBook.id]);
  }

  @override
  Future<void> delete(int id) async {
    await database.delete('numberOfBooks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAll() async {
    await database.delete('numberOfBooks');
  }

  Future<void> deleteByLibraryId(int libraryId) async {
    await database.delete('numberOfBooks', where: 'libraryId = ?', whereArgs: [libraryId]);
  }
}
