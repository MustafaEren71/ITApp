// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssignmentAdapter extends TypeAdapter<Assignment> {
  @override
  final int typeId = 2;

  @override
  Assignment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Assignment(
      employeeName: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      date: fields[3] as String,
      shelf: fields[4] as String?,
      unit: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Assignment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.employeeName)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.shelf)
      ..writeByte(5)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
