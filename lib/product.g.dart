// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      brand: fields[2] as String,
      type: fields[3] as String,
      stock: fields[4] as int,
      received: fields[5] as int,
      date: fields[6] as String,
      shelf: fields[7] as String?,
      unit: fields[8] as String?,
      desc: fields[9] as String?,
      isAssigned: fields[10] as bool,
      assignedTo: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.stock)
      ..writeByte(5)
      ..write(obj.received)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.shelf)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.desc)
      ..writeByte(10)
      ..write(obj.isAssigned)
      ..writeByte(11)
      ..write(obj.assignedTo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
