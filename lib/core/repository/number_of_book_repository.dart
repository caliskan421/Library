import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/number_of_book.dart';
import '../../model/book.dart';

class NumberOfBookRepository implements BaseDbRepo<NumberOfBook> {
  final Database database;

  NumberOfBookRepository(this.database);

  @override
  Future<int> insert(NumberOfBook numberOfBook) async {
    // numberOfBook nesnesinin içinde artık libraryId de var, toJson metodu bunu döndürecek.
    // Book ID'sinin de numberOfBook.book.id olarak mevcut olması gerektiğini unutmayın.
    if (numberOfBook.book.id == null) {
      throw Exception("Book ID must be set for NumberOfBook before inserting.");
    }
    if (numberOfBook.libraryId == null) {
      throw Exception("Library ID must be set for NumberOfBook before inserting.");
    }

    return await database.insert('numberOfBooks', numberOfBook.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // insertNumberOfBook metodu artık kaldırılabilir, çünkü insert metodu aynı işi yapacak.
  // Future<int> insertNumberOfBook(NumberOfBook numberOfBook, int libraryId) async { ... }

  @override
  Future<NumberOfBook?> get(int id) async {
    // Burayı daha verimli hale getirebiliriz. Tek bir JOIN sorgusu ile Book bilgisini de alabiliriz.
    // Tıpkı getAll metodu gibi.
    final List<Map<String, dynamic>> maps = await database.rawQuery(
      """
      SELECT
        nb.id AS numberOfBook_id,
        nb.number AS numberOfBook_number,
        nb.libraryId AS libraryId, -- libraryId'yi de çekiyoruz
        b.id AS book_id,
        b.name AS book_name,
        b.writer AS book_writer,
        b.numberOfPages AS book_numberOfPages
      FROM numberOfBooks AS nb
      JOIN books AS b ON nb.bookId = b.id
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
        nb.libraryId AS libraryId, -- libraryId'yi de çekiyoruz
        b.id AS book_id,
        b.name AS book_name,
        b.writer AS book_writer,
        b.numberOfPages AS book_numberOfPages
      FROM numberOfBooks AS nb
      JOIN books AS b ON nb.bookId = b.id
    """);

    return List.generate(maps.length, (i) {
      return NumberOfBook.fromJsonWithBook(maps[i]);
    });
  }

  @override
  Future<int> update(NumberOfBook numberOfBook) async {
    if (numberOfBook.id == null) {
      throw Exception("NumberOfBook ID cannot be null for update operation.");
    }
    // libraryId'nin de güncellenmesi gerekiyorsa, NumberOfBook modelinde olmalı.
    // Şu an için sadece mevcut NumberOfBook alanlarını güncelliyoruz.
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

  // Belirli bir Library'ye ait tüm NumberOfBook kayıtlarını silmek için
  Future<void> deleteByLibraryId(int libraryId) async {
    await database.delete('numberOfBooks', where: 'libraryId = ?', whereArgs: [libraryId]);
  }
}
