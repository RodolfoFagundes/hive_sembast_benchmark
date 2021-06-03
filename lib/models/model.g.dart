// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestEntityAdapter extends TypeAdapter<TestEntity> {
  @override
  final int typeId = 1;

  @override
  TestEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestEntity()
      ..id = fields[0] as int
      ..tString = fields[1] as String
      ..tInt = fields[2] as int
      ..tLong = fields[3] as int
      ..tDouble = fields[4] as double;
  }

  @override
  void write(BinaryWriter writer, TestEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tString)
      ..writeByte(2)
      ..write(obj.tInt)
      ..writeByte(3)
      ..write(obj.tLong)
      ..writeByte(4)
      ..write(obj.tDouble);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
