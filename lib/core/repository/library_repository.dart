import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/library.dart';
import '../../model/number_of_book.dart'; // NumberOfBook modelini de import edelim

class LibraryRepository implements BaseDbRepo<Library> {
  final Database database;

  LibraryRepository(this.database);

  @override
  Future<int> insert(Library library) async {
    return await database.insert('libraries', library.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<Library?> get(int id) async {
    final List<Map<String, dynamic>> maps = await database.query('libraries', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      final Library library = Library.fromJson(maps.first);
      // Kütüphane çekildikten sonra, ilgili NumberOfBook kayıtlarını çekip doldurmalıyız.
      // Bu kısım genellikle ayrı bir metotla veya dışarıdan yapılır.
      // Şimdilik sadece kütüphane nesnesini döndürüyoruz.
      return library;
    }
    return null;
  }

  /// Bu metot, bir kütüphaneyi ve ona ait tüm kitap sayılarını (NumberOfBook) çeker.
  Future<Library?> getLibraryWithBooks(int libraryId) async {
    final List<Map<String, dynamic>> libraryMaps = await database.query('libraries', where: 'id = ?', whereArgs: [libraryId]);

    if (libraryMaps.isEmpty) {
      return null;
    }

    final Library library = Library.fromJson(libraryMaps.first);

    // NumberOfBook ve Book bilgilerini JOIN ile çekiyoruz
    final List<Map<String, dynamic>> numberOfBookMaps = await database.rawQuery(
      """
      SELECT
        nb.id AS numberOfBook_id,
        nb.number AS numberOfBook_number,
        b.id AS book_id,
        b.name AS book_name,
        b.writer AS book_writer,
        b.numberOfPages AS book_numberOfPages
      FROM numberOfBooks AS nb
      JOIN books AS b ON nb.bookId = b.id
      WHERE nb.libraryId = ?
    """,
      [libraryId],
    );

    final List<NumberOfBook> numberOfBooks = numberOfBookMaps.map((map) {
      return NumberOfBook.fromJsonWithBook(map);
    }).toList();

    return Library(id: library.id, name: library.name, location: library.location, numberOfBook: numberOfBooks);
  }

  @override
  Future<List<Library>> getAll() async {
    final List<Map<String, dynamic>> maps = await database.query('libraries');
    return List.generate(maps.length, (i) {
      return Library.fromJson(maps[i]);
    });
  }

  @override
  Future<int> update(Library library) async {
    if (library.id == null) {
      throw Exception("Library ID cannot be null for update operation.");
    }
    return await database.update('libraries', library.toJson(), where: 'id = ?', whereArgs: [library.id]);
  }

  @override
  Future<void> delete(int id) async {
    // Kütüphane silinirken ilgili NumberOfBook kayıtlarını da silmelisiniz
    // Aksi takdirde "orphan" (sahipsiz) kayıtlar oluşur.
    await database.delete('numberOfBooks', where: 'libraryId = ?', whereArgs: [id]);
    await database.delete('libraries', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAll() async {
    await database.delete('numberOfBooks'); // Tüm NumberOfBook kayıtlarını sil
    await database.delete('libraries'); // Tüm kütüphaneleri sil
  }
}
