// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackedItemAdapter extends TypeAdapter<TrackedItem> {
  @override
  final int typeId = 0;

  @override
  TrackedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackedItem(
      id: fields[0] as String,
      name: fields[1] as String,
      iconName: fields[2] as String,
      recommendedIntervalDays: fields[3] as int,
      lastResetDate: fields[4] as DateTime,
      color: fields[5] as String,
      notificationsEnabled: fields[6] as bool,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackedItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconName)
      ..writeByte(3)
      ..write(obj.recommendedIntervalDays)
      ..writeByte(4)
      ..write(obj.lastResetDate)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.notificationsEnabled)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
