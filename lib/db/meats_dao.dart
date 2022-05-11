import 'package:memory_weakness/constants.dart';
import 'package:memory_weakness/db/db_provider.dart';
import 'package:memory_weakness/db/meats.dart';

class MeatDao {
  final DBProvider _dbProvider = DBProvider();

  Future<List<Meat>> findAll() async {
    final db = await _dbProvider.database;
    final result = await db!.query(tableNameMeats);
    final meats = List.generate(result.length, (i) {
      return Meat.fromMap(result[i]);
    });
    return meats;
  }

  Future<Meat> findById(int id) async {
    final db = await _dbProvider.database;
    final result =
        await db!.query(tableNameMeats, where: 'id=?', whereArgs: [id]);
    final meat = Meat.fromMap(result[0]);
    return meat;
  }

  Future<List<int>> findByState(int state) async {
    final db = await _dbProvider.database;
    final result =
        await db!.query(tableNameMeats, where: 'state=?', whereArgs: [state]);
    var eachStateList = <int>[];
    for (var i = 0; i < result.length; i++) {
      eachStateList.add(result[i]['id'] as int);
    }
    return eachStateList;
  }

  Future<List<int>> findByKind(String kind) async {
    final db = await _dbProvider.database;
    final result =
        await db!.query(tableNameMeats, where: 'kind=?', whereArgs: [kind]);
    var eachKindList = <int>[];
    for (var i = 0; i < result.length; i++) {
      eachKindList.add(result[i]['id'] as int);
    }
    return eachKindList;
  }

  Future<List<String>> createKindList() async {
    final db = await _dbProvider.database;
    final result = await db!.query(tableNameMeats);
    var kindList = <String>[];
    for (var i = 0; i < result.length; i++) {
      kindList.add(result[i]['kind'] as String);
    }
    final tmp = kindList.toSet().toList();
    return tmp;
  }

  Future<int> update(int id, Meat meat) async {
    final db = await _dbProvider.database;
    final result = await db!.update(
      tableNameMeats,
      meat.toMapExceptId(),
      where: 'id=?',
      whereArgs: [id],
    );
    return result;
  }
}
