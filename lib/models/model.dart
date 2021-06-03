import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 1)
class TestEntity {
  @HiveField(0)
  int /*?*/ id;

  @HiveField(1)
  String /*?*/ tString;

  @HiveField(2)
  int /*?*/ tInt; // 32-bit

  @HiveField(3)
  int /*?*/ tLong; // 64-bit

  @HiveField(4)
  double /*?*/ tDouble;

  TestEntity({id, tString, tInt, tLong, tDouble});

  TestEntity.full(this.id, this.tString, this.tInt, this.tLong, this.tDouble);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tString': tString,
      'tInt': tInt,
      'tLong': tLong,
      'tDouble': tDouble
    };
  }

  factory TestEntity.fromMap(Map<String, dynamic> map) {
    return TestEntity.full(
      map['id'],
      map['tString'],
      map['tInt'],
      map['tLong'],
      map['tDouble'],
    );
  }

  TestEntity fromMap(Map<String, dynamic> map) => TestEntity.full(
      map['id'], map['tString'], map['tInt'], map['tLong'], map['tDouble']);
}
