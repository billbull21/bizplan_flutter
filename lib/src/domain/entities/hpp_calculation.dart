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

  /// Total produksi per bulan
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
      jumlahProduksiPerHari: jumlahProduksiPerHari ?? this.jumlahProduksiPerHari,
      jumlahProduksiBatch: jumlahProduksiBatch ?? this.jumlahProduksiBatch,
      frekuensiBatchPerBulan: frekuensiBatchPerBulan ?? this.frekuensiBatchPerBulan,
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

/// Entity untuk HPP Calculator dengan struktur baru
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

  /// Total biaya dari semua komponen
  double get totalBiaya {
    return komponenBiaya.fold(0.0, (sum, komponen) {
      return sum + komponen.hitungTotalBiaya(
        settingProduksi.jumlahProduksiPerHari,
        hariProduksiPerBulan: settingProduksi.hariKerjaBulan,
      );
    });
  }

  /// HPP per unit
  double get hppPerUnit {
    final jumlahProduksi = settingProduksi.jumlahProduksiPerHari;
    if (jumlahProduksi <= 0) return 0;
    return totalBiaya / jumlahProduksi;
  }

  /// Harga jual per unit (HPP + profit margin)
  double get hargaJualPerUnit {
    return hppPerUnit * (1 + (profitMargin / 100));
  }

  /// Profit per unit
  double get profitPerUnit {
    return hargaJualPerUnit - hppPerUnit;
  }

  /// Total profit untuk produksi harian
  double get totalProfitHarian {
    return profitPerUnit * settingProduksi.jumlahProduksiPerHari;
  }

  /// Total profit untuk produksi bulanan
  double get totalProfitBulanan {
    return profitPerUnit * settingProduksi.totalProduksiBulan;
  }

  /// Breakdown biaya berdasarkan periode
  Map<String, double> get breakdownBiayaByPeriode {
    final breakdown = <String, double>{
      'harian': 0.0,
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
