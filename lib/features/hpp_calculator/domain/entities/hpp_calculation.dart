import 'package:equatable/equatable.dart';
import 'komponen_biaya.dart';
import 'jenis_produksi.dart';
import 'skala_usaha.dart';

/// Entity untuk pengaturan produksi
class SettingProduksi extends Equatable {
  final JenisProduksi jenisProduksi;
  final int hariKerjaBulan;
  final int jumlahProduksiPerHari;
  final int? jumlahProduksiBatch;
  final int? frekuensiBatchPerBulan;

  const SettingProduksi({
    required this.jenisProduksi,
    this.hariKerjaBulan = 25,
    this.jumlahProduksiPerHari = 1,
    this.jumlahProduksiBatch,
    this.frekuensiBatchPerBulan,
  });

  int get totalProduksiBulan {
    switch (jenisProduksi) {
      case JenisProduksi.harian:
        return jumlahProduksiPerHari * hariKerjaBulan;
      case JenisProduksi.batch:
        return (jumlahProduksiBatch ?? 0) * (frekuensiBatchPerBulan ?? 1);
      case JenisProduksi.bulanan:
      case JenisProduksi.custom:
        return jumlahProduksiPerHari * hariKerjaBulan;
    }
  }

  SettingProduksi copyWith({
    JenisProduksi? jenisProduksi,
    int? hariKerjaBulan,
    int? jumlahProduksiPerHari,
    int? jumlahProduksiBatch,
    int? frekuensiBatchPerBulan,
  }) {
    return SettingProduksi(
      jenisProduksi: jenisProduksi ?? this.jenisProduksi,
      hariKerjaBulan: hariKerjaBulan ?? this.hariKerjaBulan,
      jumlahProduksiPerHari:
          jumlahProduksiPerHari ?? this.jumlahProduksiPerHari,
      jumlahProduksiBatch: jumlahProduksiBatch ?? this.jumlahProduksiBatch,
      frekuensiBatchPerBulan:
          frekuensiBatchPerBulan ?? this.frekuensiBatchPerBulan,
    );
  }

  @override
  List<Object?> get props => [
        jenisProduksi,
        hariKerjaBulan,
        jumlahProduksiPerHari,
        jumlahProduksiBatch,
        frekuensiBatchPerBulan,
      ];
}

/// Entity untuk hasil perhitungan HPP
class HppCalculation extends Equatable {
  final String id;
  final String namaProduk;
  final SkalaUsaha skalaUsaha;
  final SettingProduksi settingProduksi;
  final List<KomponenBiaya> komponenBiaya;
  final double profitMargin;
  final DateTime createdAt;

  const HppCalculation({
    required this.id,
    required this.namaProduk,
    required this.skalaUsaha,
    required this.settingProduksi,
    required this.komponenBiaya,
    required this.profitMargin,
    required this.createdAt,
  });

  /// Total biaya produksi BULANAN (semua komponen dikonversi ke bulanan)
  double get totalBiayaBulanan {
    return komponenBiaya.fold(0.0, (sum, komponen) {
      return sum + komponen.hitungBiayaBulanan(
        hariKerjaBulan: settingProduksi.hariKerjaBulan,
        frekuensiBatchPerBulan: settingProduksi.frekuensiBatchPerBulan ?? 1,
      );
    });
  }

  /// Alias untuk kompatibilitas
  double get totalBiaya => totalBiayaBulanan;

  double get hppPerUnit {
    final totalProduksi = settingProduksi.totalProduksiBulan;
    if (totalProduksi <= 0) return 0;
    return totalBiayaBulanan / totalProduksi;
  }

  double get hargaJualPerUnit {
    return hppPerUnit * (1 + (profitMargin / 100));
  }

  double get profitPerUnit {
    return hargaJualPerUnit - hppPerUnit;
  }

  /// Profit per siklus produksi (per hari untuk harian, per batch untuk batch, per bulan untuk bulanan)
  double get totalProfitPerSiklus {
    switch (settingProduksi.jenisProduksi) {
      case JenisProduksi.harian:
        return profitPerUnit * settingProduksi.jumlahProduksiPerHari;
      case JenisProduksi.batch:
        return profitPerUnit * (settingProduksi.jumlahProduksiBatch ?? 0);
      case JenisProduksi.bulanan:
      case JenisProduksi.custom:
        return profitPerUnit * settingProduksi.totalProduksiBulan;
    }
  }

  double get totalProfitBulanan {
    return profitPerUnit * settingProduksi.totalProduksiBulan;
  }

  /// Biaya variabel per unit = (total biaya - biaya tetap) / total produksi
  /// Digunakan untuk BEP dan Profit Analysis (contribution margin approach)
  double hitungBiayaVariabelPerUnit(double biayaTetapBulanan) {
    final totalProduksi = settingProduksi.totalProduksiBulan;
    if (totalProduksi <= 0) return 0;
    final biayaVariabel = totalBiayaBulanan - biayaTetapBulanan;
    return biayaVariabel < 0 ? 0 : biayaVariabel / totalProduksi;
  }

  Map<String, double> get breakdownBiayaByPeriode {
    final breakdown = <String, double>{
      'harian': 0.0,
      'perBatch': 0.0,
      'mingguan': 0.0,
      'bulanan': 0.0,
    };
    for (final komponen in komponenBiaya) {
      final key = komponen.periode.name;
      breakdown[key] = (breakdown[key] ?? 0.0) + komponen.nilai;
    }
    return breakdown;
  }

  HppCalculation copyWith({
    String? id,
    String? namaProduk,
    SkalaUsaha? skalaUsaha,
    SettingProduksi? settingProduksi,
    List<KomponenBiaya>? komponenBiaya,
    double? profitMargin,
    DateTime? createdAt,
  }) {
    return HppCalculation(
      id: id ?? this.id,
      namaProduk: namaProduk ?? this.namaProduk,
      skalaUsaha: skalaUsaha ?? this.skalaUsaha,
      settingProduksi: settingProduksi ?? this.settingProduksi,
      komponenBiaya: komponenBiaya ?? this.komponenBiaya,
      profitMargin: profitMargin ?? this.profitMargin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        namaProduk,
        skalaUsaha,
        settingProduksi,
        komponenBiaya,
        profitMargin,
        createdAt,
      ];
}
