import 'package:equatable/equatable.dart';

/// Entity untuk analisis profit
class ProfitAnalysis extends Equatable {
  /// Biaya variabel per unit (bukan HPP penuh — HPP sudah termasuk biaya tetap)
  /// Gunakan contribution margin approach: revenue - biayaVariabel - biayaTetap
  final double biayaVariabelPerUnit;
  final double hargaJualPerUnit;
  final int jumlahProduksi;
  final int targetPenjualan;
  final double biayaTetapBulanan;
  final double? investasiAwal;

  const ProfitAnalysis({
    required this.biayaVariabelPerUnit,
    required this.hargaJualPerUnit,
    required this.jumlahProduksi,
    required this.targetPenjualan,
    required this.biayaTetapBulanan,
    this.investasiAwal,
  });

  /// Contribution margin per unit = harga jual - biaya variabel
  double get grossProfitPerUnit => hargaJualPerUnit - biayaVariabelPerUnit;

  double get grossProfitMargin {
    if (hargaJualPerUnit <= 0) return 0;
    return (grossProfitPerUnit / hargaJualPerUnit) * 100;
  }

  /// Total contribution = CM/unit × target penjualan
  double get totalGrossProfit => grossProfitPerUnit * targetPenjualan;

  /// Net profit = total contribution - biaya tetap bulanan
  double get netProfit => totalGrossProfit - biayaTetapBulanan;

  double get netProfitMargin {
    final totalRevenue = hargaJualPerUnit * targetPenjualan;
    if (totalRevenue <= 0) return 0;
    return (netProfit / totalRevenue) * 100;
  }

  double get roi {
    if (investasiAwal == null || investasiAwal! <= 0) return 0;
    return (netProfit / investasiAwal!) * 100;
  }

  double get paybackPeriodBulan {
    if (investasiAwal == null || investasiAwal! <= 0 || netProfit <= 0) {
      return 0;
    }
    return investasiAwal! / netProfit;
  }

  ProfitAnalysis copyWith({
    double? biayaVariabelPerUnit,
    double? hargaJualPerUnit,
    int? jumlahProduksi,
    int? targetPenjualan,
    double? biayaTetapBulanan,
    double? investasiAwal,
  }) {
    return ProfitAnalysis(
      biayaVariabelPerUnit: biayaVariabelPerUnit ?? this.biayaVariabelPerUnit,
      hargaJualPerUnit: hargaJualPerUnit ?? this.hargaJualPerUnit,
      jumlahProduksi: jumlahProduksi ?? this.jumlahProduksi,
      targetPenjualan: targetPenjualan ?? this.targetPenjualan,
      biayaTetapBulanan: biayaTetapBulanan ?? this.biayaTetapBulanan,
      investasiAwal: investasiAwal ?? this.investasiAwal,
    );
  }

  @override
  List<Object?> get props => [
        biayaVariabelPerUnit,
        hargaJualPerUnit,
        jumlahProduksi,
        targetPenjualan,
        biayaTetapBulanan,
        investasiAwal,
      ];
}
