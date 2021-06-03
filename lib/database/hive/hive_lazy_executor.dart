import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_sembast_benchmark/models/model.dart';

import '../executor.dart';
import '../time_tracker.dart';

class HiveLazyExecutor extends ExecutorBase {
  static final _boxName = 'TestEntity';

  LazyBox<TestEntity> _box;

  HiveLazyExecutor._(this._box, TimeTracker tracker) : super(tracker);

  static Future<HiveLazyExecutor> create(
      Directory dbDir, TimeTracker tracker) async {
    if (!Hive.isAdapterRegistered(TestEntityAdapter().typeId)) {
      Hive.registerAdapter(TestEntityAdapter());
    }
    await Hive.close();
    return HiveLazyExecutor._(await Hive.openLazyBox(_boxName), tracker);
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
    return tracker.trackAsync(
        'readMany', () => Future.wait(ids.map(_box.get).toList()));
  }

  Future<void> removeMany(List<int> ids) async =>
      tracker.track('removeMany', () async {
        await _box.deleteAll(ids);
        await _box.compact();
      });

  Future<List<TestEntity>> readAll() async {
    return null;
  }

  Future<String> json() async {
    return "";
  }
}
