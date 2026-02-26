// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reel_idea.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReelIdeaAdapter extends TypeAdapter<ReelIdea> {
  @override
  final int typeId = 0;

  @override
  ReelIdea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReelIdea(
      id: fields[0] as String,
      title: fields[1] as String,
      scriptText: fields[2] as String,
      backgroundImageUrl: fields[3] as String?,
      status: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReelIdea obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.scriptText)
      ..writeByte(3)
      ..write(obj.backgroundImageUrl)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReelIdeaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
