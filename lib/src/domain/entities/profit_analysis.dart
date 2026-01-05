import 'package:equatable/equatable.dart';

/// Entity untuk analisis profit
class ProfitAnalysis extends Equatable {
  final double hppPerUnit;
  final double hargaJualPerUnit;
  final int jumlahProduksi;
  final int targetPenjualan;
  final double biayaTetapBulanan;
  final double? investasiAwal;

  const ProfitAnalysis({
    required this.hppPerUnit,
    required this.hargaJualPerUnit,
    required this.jumlahProduksi,
    required this.targetPenjualan,
    required this.biayaTetapBulanan,
    this.investasiAwal,
  });

  /// Gross Profit per unit
  double get grossProfitPerUnit {
    return hargaJualPerUnit - hppPerUnit;
  }

  /// Gross Profit Margin (%)
  double get grossProfitMargin {
    if (hargaJualPerUnit <= 0) return 0;
    return (grossProfitPerUnit / hargaJualPerUnit) * 100;
  }

  /// Total Gross Profit
  double get totalGrossProfit {
    return grossProfitPerUnit * targetPenjualan;
  }

  /// Net Profit (setelah dikurangi biaya tetap)
  double get netProfit {
    return totalGrossProfit - biayaTetapBulanan;
  }

  /// Net Profit Margin (%)
  double get netProfitMargin {
    final totalRevenue = hargaJualPerUnit * targetPenjualan;
    if (totalRevenue <= 0) return 0;
    return (netProfit / totalRevenue) * 100;
  }

  /// ROI (Return on Investment) jika ada investasi awal
  double get roi {
    if (investasiAwal == null || investasiAwal! <= 0) return 0;
    return (netProfit / investasiAwal!) * 100;
  }

  /// Payback Period dalam bulan (jika ada investasi awal)
  double get paybackPeriodBulan {
    if (investasiAwal == null || investasiAwal! <= 0 || netProfit <= 0) return 0;
    return investasiAwal! / netProfit;
  }

  /// Proyeksi profit untuk beberapa bulan
  List<ProyeksiProfit> proyeksiBulanan(int jumlahBulan, List<int> targetPenjualanPerBulan) {
    final proyeksi = <ProyeksiProfit>[];
    double akumulasiProfit = 0;

    for (int i = 0; i < jumlahBulan && i < targetPenjualanPerBulan.length; i++) {
      final target = targetPenjualanPerBulan[i];
      final grossProfit = grossProfitPerUnit * target;
      final netProfit = grossProfit - biayaTetapBulanan;
      akumulasiProfit += netProfit;

      proyeksi.add(ProyeksiProfit(
        bulan: i + 1,
        targetPenjualan: target,
        grossProfit: grossProfit,
        netProfit: netProfit,
        akumulasiProfit: akumulasiProfit,
      ));
    }

    return proyeksi;
  }

  ProfitAnalysis copyWith({
    double? hppPerUnit,
    double? hargaJualPerUnit,
    int? jumlahProduksi,
    int? targetPenjualan,
    double? biayaTetapBulanan,
    double? investasiAwal,
  }) {
    return ProfitAnalysis(
      hppPerUnit: hppPerUnit ?? this.hppPerUnit,
      hargaJualPerUnit: hargaJualPerUnit ?? this.hargaJualPerUnit,
      jumlahProduksi: jumlahProduksi ?? this.jumlahProduksi,
      targetPenjualan: targetPenjualan ?? this.targetPenjualan,
      biayaTetapBulanan: biayaTetapBulanan ?? this.biayaTetapBulanan,
      investasiAwal: investasiAwal ?? this.investasiAwal,
    );
  }

  @override
  List<Object?> get props => [
        hppPerUnit,
        hargaJualPerUnit,
        jumlahProduksi,
        targetPenjualan,
        biayaTetapBulanan,
        investasiAwal,
      ];
}

/// Entity untuk proyeksi profit per bulan
class ProyeksiProfit extends Equatable {
  final int bulan;
  final int targetPenjualan;
  final double grossProfit;
  final double netProfit;
  final double akumulasiProfit;

  const ProyeksiProfit({
    required this.bulan,
    required this.targetPenjualan,
    required this.grossProfit,
    required this.netProfit,
    required this.akumulasiProfit,
  });

  @override
  List<Object?> get props => [
        bulan,
        targetPenjualan,
        grossProfit,
        netProfit,
        akumulasiProfit,
      ];
}
