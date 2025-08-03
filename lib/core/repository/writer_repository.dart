import 'package:sqflite/sqflite.dart';
import 'package:where_is_library/core/repository/base_db_repo.dart';
import '../../model/writer.dart';

class WriterRepository implements BaseDbRepo<Writer> {
  final Database database;

  WriterRepository(this.database);

  @override
  Future<int> insert(Writer writer) async {
    return await database.insert('writers', writer.toJson(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  @override
  Future<Writer?> get(int id) async {
    final List<Map<String, dynamic>> maps = await database.query('writers', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Writer.fromJson(maps.first);
    }
    return null;
  }

  // Yazar adına göre yazar çekmek için özel bir metot eklenebilir
  Future<Writer?> getByName(String name) async {
    final List<Map<String, dynamic>> maps = await database.query('writers', where: 'name = ?', whereArgs: [name]);
    if (maps.isNotEmpty) {
      return Writer.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<List<Writer>> getAll() async {
    final List<Map<String, dynamic>> maps = await database.query('writers');
    return List.generate(maps.length, (i) {
      return Writer.fromJson(maps[i]);
    });
  }

  @override
  Future<int> update(Writer writer) async {
    if (writer.id == null) {
      throw Exception("Writer ID cannot be {null} for [update] operation.");
    }
    return await database.update('writers', writer.toJson(), where: 'id = ?', whereArgs: [writer.id]);
  }

  @override
  Future<void> delete(int id) async {
    await database.delete('writers', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAll() async {
    await database.delete('writers');
  }
}
