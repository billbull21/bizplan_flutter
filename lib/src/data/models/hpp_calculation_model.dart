import '../../domain/entities/skala_usaha.dart';
import '../../domain/entities/hpp_calculation.dart';
import 'komponen_biaya_model.dart';
import 'setting_produksi_model.dart';

/// Data model untuk HppCalculation dengan JSON serialization
class HppCalculationModel extends HppCalculation {
  const HppCalculationModel({
    required super.id,
    required super.namaProduk,
    required super.skalaUsaha,
    required super.settingProduksi,
    required super.komponenBiaya,
    required super.profitMargin,
    required super.createdAt,
  });

  factory HppCalculationModel.fromEntity(HppCalculation entity) {
    return HppCalculationModel(
      id: entity.id,
      namaProduk: entity.namaProduk,
      skalaUsaha: entity.skalaUsaha,
      settingProduksi: entity.settingProduksi,
      komponenBiaya: entity.komponenBiaya,
      profitMargin: entity.profitMargin,
      createdAt: entity.createdAt,
    );
  }

  factory HppCalculationModel.fromJson(Map<String, dynamic> json) {
    return HppCalculationModel(
      id: json['id'] as String,
      namaProduk: json['namaProduk'] as String,
      skalaUsaha: SkalaUsaha.values[json['skalaUsaha'] as int],
      settingProduksi: SettingProduksiModel.fromJson(
        json['settingProduksi'] as Map<String, dynamic>,
      ),
      komponenBiaya: (json['komponenBiaya'] as List)
          .map((e) => KomponenBiayaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaProduk': namaProduk,
      'skalaUsaha': skalaUsaha.index,
      'settingProduksi':
          SettingProduksiModel.fromEntity(settingProduksi).toJson(),
      'komponenBiaya': komponenBiaya
          .map((e) => KomponenBiayaModel.fromEntity(e).toJson())
          .toList(),
      'profitMargin': profitMargin,
      'createdAt': createdAt.toIso8601String(),
      // Computed values untuk backward compatibility
      'hppPerUnit': hppPerUnit,
      'hargaJualPerUnit': hargaJualPerUnit,
      'totalBiaya': totalBiaya,
    };
  }

  HppCalculation toEntity() {
    return HppCalculation(
      id: id,
      namaProduk: namaProduk,
      skalaUsaha: skalaUsaha,
      settingProduksi: settingProduksi,
      komponenBiaya: komponenBiaya,
      profitMargin: profitMargin,
      createdAt: createdAt,
    );
  }
}
