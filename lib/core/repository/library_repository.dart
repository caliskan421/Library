import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/library.dart';
import '../../model/library_location.dart';
import '../../model/number_of_book.dart';

class LibraryRepository implements BaseDbRepo<Library> {
  final Database database;

  LibraryRepository(this.database);

  @override
  Future<int> insert(Library library) async {
    return await database.insert(
      'libraries',
      library.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // [?] Bu metot gereksiz !!!
  @override
  Future<Library?> get(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'libraries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final Library library = Library.fromJson(maps.first);
      // [!] Kütüphane çekildikten sonra, ilgili NumberOfBook kayıtlarını çekip doldurmalıyız.
      // [!] Bu kısım genellikle ayrı bir metotla veya dışarıdan yapılır.
      // [!] Şimdilik sadece kütüphane nesnesini döndürüyoruz.
      return library;
    }
    return null;
  }

  // --> Bu metot, bir kütüphaneyi, lokasyonunu ve ona ait tüm kitap sayılarını (NumberOfBook) çeker.
  Future<Library?> getLibraryWithBooks(int libraryId) async {
    // [!] Library ve LibraryLocation'ı JOIN ile çekiyoruz
    final List<Map<String, dynamic>> libraryMaps = await database.rawQuery(
      """
      SELECT 
        l.id AS library_id,
        l.name AS library_name,
        l.locationId AS library_locationId,
        ll.id AS location_id,
        ll.title AS location_title,
        ll.lat AS location_lat,
        ll.long AS location_long
      FROM libraries AS l
      LEFT JOIN library_locations AS ll ON l.locationId = ll.id
      WHERE l.id = ?
      """,
      [libraryId],
    );

    if (libraryMaps.isEmpty) {
      return null;
    }

    final Map<String, dynamic> libraryData = libraryMaps.first;

    // LibraryLocation oluştur (eğer varsa)
    LibraryLocation? location;
    if (libraryData['location_id'] != null) {
      location = LibraryLocation(
        id: libraryData['location_id'],
        title: libraryData['location_title'],
        lat: libraryData['location_lat'],
        long: libraryData['location_long'],
      );
    }

    // Library oluştur
    final Library library = Library(
      id: libraryData['library_id'],
      name: libraryData['library_name'],
      locationId: libraryData['library_locationId'],
      location: location,
    );

    // [!] [NumberOfBook], [Book] ve [Writer] bilgilerini {JOIN} ile çekiyoruz
    final List<Map<String, dynamic>> numberOfBookMaps = await database.rawQuery(
      """
      SELECT
        nb.id AS numberOfBook_id,
        nb.number AS numberOfBook_number,
        nb.libraryId AS libraryId, -- numberOfBooks'taki libraryId
        b.id AS book_id,
        b.name AS book_name,
        b.numberOfPages AS book_numberOfPages,
        b.writerId AS book_writerId, -- Book'taki writerId
        w.id AS writer_id, -- Writer tablosundaki id
        w.name AS writer_name -- Writer tablosundaki name
      FROM numberOfBooks AS nb
      JOIN books AS b ON nb.bookId = b.id
      LEFT JOIN writers AS w ON b.writerId = w.id -- Buraya yeni JOIN eklendi!
      WHERE nb.libraryId = ?
    """,
      [libraryId],
    );

    final List<NumberOfBook> numberOfBooks = numberOfBookMaps.map((map) {
      // Artık NumberOfBook.fromJsonWithBook metoduna Book'un writer'ını da iletecek şekilde güncelledik.
      return NumberOfBook.fromJsonWithBook(map);
    }).toList();

    return Library(
      id: library.id,
      name: library.name,
      locationId: library.locationId,
      location: library.location,
      numberOfBook: numberOfBooks,
    );
  }

  @override
  Future<List<Library>> getAll() async {
    final List<Map<String, dynamic>> maps = await database.query('libraries');
    return List.generate(maps.length, (i) {
      return Library.fromJson(maps[i]);
    });
  }

  // --> Tüm kütüphaneleri location bilgileriyle birlikte çeker
  Future<List<Library>> getAllWithLocations() async {
    final List<Map<String, dynamic>> libraryMaps = await database.rawQuery("""
      SELECT 
        l.id AS library_id,
        l.name AS library_name,
        l.locationId AS library_locationId,
        ll.id AS location_id,
        ll.title AS location_title,
        ll.lat AS location_lat,
        ll.long AS location_long
      FROM libraries AS l
      LEFT JOIN library_locations AS ll ON l.locationId = ll.id
      ORDER BY l.name
      """);

    return libraryMaps.map((libraryData) {
      // LibraryLocation oluştur (eğer varsa)
      LibraryLocation? location;
      if (libraryData['location_id'] != null) {
        location = LibraryLocation(
          id: libraryData['location_id'],
          title: libraryData['location_title'],
          lat: libraryData['location_lat'],
          long: libraryData['location_long'],
        );
      }

      // Library oluştur
      return Library(
        id: libraryData['library_id'],
        name: libraryData['library_name'],
        locationId: libraryData['library_locationId'],
        location: location,
      );
    }).toList();
  }

  @override
  Future<int> update(Library library) async {
    if (library.id == null) {
      throw Exception("Library ID cannot be {null} for [updat] operation.");
    }
    return await database.update(
      'libraries',
      library.toJson(),
      where: 'id = ?',
      whereArgs: [library.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    // [!] Kütüphane silinirken ilgili NumberOfBook kayıtlarını da silmelisiniz [otherwise]--> {"orphan" (sahipsiz) kayıtlar}
    await database.delete(
      'numberOfBooks',
      where: 'libraryId = ?',
      whereArgs: [id],
    );
    await database.delete('libraries', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAll() async {
    await database.delete('numberOfBooks');
    await database.delete('libraries');
  }
}
