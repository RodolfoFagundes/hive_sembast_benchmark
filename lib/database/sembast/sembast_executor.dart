import 'package:hive_sembast_benchmark/database/time_tracker.dart';
import 'package:hive_sembast_benchmark/models/model.dart';
import 'package:sembast/sembast.dart';

import '../executor.dart';
import 'app_database.dart';

class SembastExecutor extends ExecutorBase {
  final Database _db;
  static const String folderName = 'testentity';
  final _testentityFolder = intMapStoreFactory.store(folderName);

  SembastExecutor._(this._db, TimeTracker tracker) : super(tracker);

  static Future<SembastExecutor> create(TimeTracker tracker) async =>
      SembastExecutor._(await AppDatabase.instance.database, tracker);

  void close() => _db.close();

  Future insertMany(List<TestEntity> items) async =>
      tracker.trackAsync('insertMany', () async {
        List<Map<String, Object>> values = [];

        int id = 1;
        items.forEach((element) {
          element.id ??= id++;
          values.add(element.toMap());
        });

        return await _testentityFolder.addAll(_db, values);
      });

  Future updateMany(List<TestEntity> items) async =>
      tracker.trackAsync('updateMany', () async {
        var database = _db;
        items.forEach((element) async =>
            await _testentityFolder.update(database, element.toMap()));
      });

  Future<List<TestEntity>> readMany(List<int> ids) =>
      tracker.trackAsync('readMany', () async {
        final recordSnapshot = await _testentityFolder.find(_db,
            finder: Finder(filter: Filter.inList('id', ids)));
        return recordSnapshot.map((e) {
          return TestEntity.fromMap(e.value);
        }).toList();
      });

  Future delete(TestEntity testentity) async {
    final finder = Finder(filter: Filter.byKey(testentity.id));
    await _testentityFolder.delete(_db, finder: finder);
  }

  Future<void> removeMany(List<int> ids) async =>
      tracker.track('removeMany', () async {
        _testentityFolder.delete(_db,
            finder: Finder(filter: Filter.byKey(ids)));
      });

  Future<List<TestEntity>> readAll() async {
    final recordSnapshot = await _testentityFolder.find(_db);
    return recordSnapshot.map((e) {
      return TestEntity.fromMap(e.value);
    }).toList();
  }

  @override
  Future<String> json() {
    throw UnimplementedError();
  }
}
