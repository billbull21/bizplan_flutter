import '../../domain/entities/periode_komponen.dart';
import '../../domain/entities/komponen_biaya.dart';

/// Data model untuk KomponenBiaya dengan JSON serialization
class KomponenBiayaModel extends KomponenBiaya {
  const KomponenBiayaModel({
    required super.id,
    required super.nama,
    required super.nilai,
    required super.periode,
    super.keterangan,
  });

  factory KomponenBiayaModel.fromEntity(KomponenBiaya entity) {
    return KomponenBiayaModel(
      id: entity.id,
      nama: entity.nama,
      nilai: entity.nilai,
      periode: entity.periode,
      keterangan: entity.keterangan,
    );
  }

  factory KomponenBiayaModel.fromJson(Map<String, dynamic> json) {
    return KomponenBiayaModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      nilai: (json['nilai'] as num).toDouble(),
      periode: PeriodeKomponen.values[json['periode'] as int],
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nilai': nilai,
      'periode': periode.index,
      'keterangan': keterangan,
    };
  }

  KomponenBiaya toEntity() {
    return KomponenBiaya(
      id: id,
      nama: nama,
      nilai: nilai,
      periode: periode,
      keterangan: keterangan,
    );
  }
}
