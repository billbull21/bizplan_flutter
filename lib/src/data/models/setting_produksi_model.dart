import '../../domain/entities/jenis_produksi.dart';
import '../../domain/entities/hpp_calculation.dart';

/// Data model untuk SettingProduksi dengan JSON serialization
class SettingProduksiModel extends SettingProduksi {
  const SettingProduksiModel({
    required super.jenisProduksi,
    super.hariKerjaBulan = 25,
    super.jumlahProduksiPerHari = 1,
    super.jumlahProduksiBatch,
    super.frekuensiBatchPerBulan,
  });

  factory SettingProduksiModel.fromEntity(SettingProduksi entity) {
    return SettingProduksiModel(
      jenisProduksi: entity.jenisProduksi,
      hariKerjaBulan: entity.hariKerjaBulan,
      jumlahProduksiPerHari: entity.jumlahProduksiPerHari,
      jumlahProduksiBatch: entity.jumlahProduksiBatch,
      frekuensiBatchPerBulan: entity.frekuensiBatchPerBulan,
    );
  }

  factory SettingProduksiModel.fromJson(Map<String, dynamic> json) {
    return SettingProduksiModel(
      jenisProduksi: JenisProduksi.values[json['jenisProduksi'] as int],
      hariKerjaBulan: json['hariKerjaBulan'] as int? ?? 25,
      jumlahProduksiPerHari: json['jumlahProduksiPerHari'] as int? ?? 1,
      jumlahProduksiBatch: json['jumlahProduksiBatch'] as int?,
      frekuensiBatchPerBulan: json['frekuensiBatchPerBulan'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenisProduksi': jenisProduksi.index,
      'hariKerjaBulan': hariKerjaBulan,
      'jumlahProduksiPerHari': jumlahProduksiPerHari,
      'jumlahProduksiBatch': jumlahProduksiBatch,
      'frekuensiBatchPerBulan': frekuensiBatchPerBulan,
    };
  }

  SettingProduksi toEntity() {
    return SettingProduksi(
      jenisProduksi: jenisProduksi,
      hariKerjaBulan: hariKerjaBulan,
      jumlahProduksiPerHari: jumlahProduksiPerHari,
      jumlahProduksiBatch: jumlahProduksiBatch,
      frekuensiBatchPerBulan: frekuensiBatchPerBulan,
    );
  }
}
