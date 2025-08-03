import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/library_location.dart';

class LibraryLocationRepository implements BaseDbRepo<LibraryLocation> {
  final Database database;

  LibraryLocationRepository(this.database);

  @override
  Future<int> insert(LibraryLocation libraryLocation) async {
    return await database.insert(
      'library_locations',
      libraryLocation.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<LibraryLocation?> get(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'library_locations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return LibraryLocation.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<List<LibraryLocation>> getAll() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'library_locations',
    );
    return List.generate(maps.length, (i) {
      return LibraryLocation.fromJson(maps[i]);
    });
  }

  @override
  Future<int> update(LibraryLocation libraryLocation) async {
    if (libraryLocation.id == null) {
      throw Exception(
        "LibraryLocation ID cannot be {null} for [update] operation.",
      );
    }
    return await database.update(
      'library_locations',
      libraryLocation.toJson(),
      where: 'id = ?',
      whereArgs: [libraryLocation.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await database.delete(
      'library_locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAll() async {
    await database.delete('library_locations');
  }
}
