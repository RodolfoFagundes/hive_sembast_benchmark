import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_sembast_benchmark/models/model.dart';

import '../executor.dart';
import '../time_tracker.dart';

class HiveExecutor extends ExecutorBase {
  static final _boxName = 'TestEntity';

  Box<TestEntity> _box;

  HiveExecutor._(this._box, TimeTracker tracker) : super(tracker);

  static Future<HiveExecutor> create(
      Directory dbDir, TimeTracker tracker) async {
    if (!Hive.isAdapterRegistered(TestEntityAdapter().typeId)) {
      Hive.registerAdapter(TestEntityAdapter());
    }
    await Hive.close();
    return HiveExecutor._(await Hive.openBox(_boxName), tracker);
  }

  void close() => _box.close();

  Future<void> insertMany(List<TestEntity> items) async =>
      tracker.trackAsync('insertMany', () async {
        int id = 1;
        final itemsById = <int, TestEntity>{};
        items.forEach((TestEntity o) {
          o.id ??= id++;
          itemsById[o.id] = o;
        });
        return await _box.putAll(itemsById);
      });

  Future<void> updateMany(List<TestEntity> items) async => tracker.trackAsync(
      'updateMany',
      () async => await _box.putAll(Map<int, TestEntity>.fromIterable(items,
          key: (o) => o.id, value: (o) => o)));

  Future<List<TestEntity>> readMany(List<int> ids) async {
    return Future.value(
        tracker.track('readMany', () => ids.map(_box.get).toList()));
  }

  Future<void> removeMany(List<int> ids) async =>
      tracker.track('removeMany', () async {
        await _box.deleteAll(ids);
        await _box.compact();
      });

  Future<List<TestEntity>> readAll() async {
    return Future.value(tracker.track(
        'readAll', () => _box.values.toList().cast<TestEntity>()));
  }

  Future<String> json() async {
    return jsonEncode(_box
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value.toMap())));
  }
}
