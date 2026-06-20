// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mesure_glycemie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MesureGlycemieAdapter extends TypeAdapter<MesureGlycemie> {
  @override
  final int typeId = 0;

  @override
  MesureGlycemie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MesureGlycemie()
      ..valeur = fields[0] as double
      ..date = fields[1] as DateTime
      ..moment = fields[2] as String
      ..note = fields[3] as String
      ..estSynchronisee = fields[4] as bool
      ..idFhir = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, MesureGlycemie obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.valeur)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.moment)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.estSynchronisee)
      ..writeByte(5)
      ..write(obj.idFhir);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesureGlycemieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
