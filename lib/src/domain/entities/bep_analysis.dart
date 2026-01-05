import 'package:equatable/equatable.dart';

/// Entity untuk analisis BEP (Break Even Point)
class BepAnalysis extends Equatable {
  // Biaya Tetap (Fixed Cost)
  final double biayaTetapBulanan;
  
  // Biaya Variabel per unit
  final double biayaVariabelPerUnit;
  
  // Harga jual per unit
  final double hargaJualPerUnit;
  
  // Target/Estimasi produksi per hari
  final int produksiPerHari;
  
  // Hari kerja per bulan
  final int hariKerjaBulan;

  const BepAnalysis({
    required this.biayaTetapBulanan,
    required this.biayaVariabelPerUnit,
    required this.hargaJualPerUnit,
    required this.produksiPerHari,
    this.hariKerjaBulan = 25,
  });

  /// Contribution Margin per unit
  double get contributionMargin {
    return hargaJualPerUnit - biayaVariabelPerUnit;
  }

  /// BEP dalam unit (berapa unit harus dijual untuk BEP)
  int get bepUnit {
    if (contributionMargin <= 0) return -1; // Harga terlalu rendah
    return (biayaTetapBulanan / contributionMargin).ceil();
  }

  /// BEP dalam rupiah (berapa omzet untuk BEP)
  double get bepRupiah {
    if (bepUnit < 0) return 0;
    return bepUnit * hargaJualPerUnit;
  }

  /// BEP dalam hari (berapa hari untuk mencapai BEP)
  int get bepHari {
    if (bepUnit < 0 || produksiPerHari <= 0) return -1;
    return (bepUnit / produksiPerHari).ceil();
  }

  /// BEP dalam bulan
  double get bepBulan {
    if (bepHari < 0 || hariKerjaBulan <= 0) return -1;
    return bepHari / hariKerjaBulan;
  }

  /// Target penjualan untuk profit tertentu
  int targetPenjualanUntukProfit(double targetProfit) {
    if (contributionMargin <= 0) return -1;
    return ((biayaTetapBulanan + targetProfit) / contributionMargin).ceil();
  }

  /// Margin of Safety (%)
  /// Seberapa jauh penjualan aktual dari BEP
  double marginOfSafety(int penjualanAktual) {
    if (bepUnit <= 0 || penjualanAktual <= 0) return 0;
    return ((penjualanAktual - bepUnit) / penjualanAktual) * 100;
  }

  /// Validasi apakah model bisnis viable
  bool get isViable {
    return contributionMargin > 0 && bepUnit > 0;
  }

  /// Pesan validasi jika tidak viable
  String? get validationMessage {
    if (contributionMargin <= 0) {
      return 'Harga jual terlalu rendah! Harus lebih besar dari biaya variabel.';
    }
    if (biayaTetapBulanan <= 0) {
      return 'Biaya tetap bulanan harus diisi.';
    }
    return null;
  }

  BepAnalysis copyWith({
    double? biayaTetapBulanan,
    double? biayaVariabelPerUnit,
    double? hargaJualPerUnit,
    int? produksiPerHari,
    int? hariKerjaBulan,
  }) {
    return BepAnalysis(
      biayaTetapBulanan: biayaTetapBulanan ?? this.biayaTetapBulanan,
      biayaVariabelPerUnit: biayaVariabelPerUnit ?? this.biayaVariabelPerUnit,
      hargaJualPerUnit: hargaJualPerUnit ?? this.hargaJualPerUnit,
      produksiPerHari: produksiPerHari ?? this.produksiPerHari,
      hariKerjaBulan: hariKerjaBulan ?? this.hariKerjaBulan,
    );
  }

  @override
  List<Object?> get props => [
        biayaTetapBulanan,
        biayaVariabelPerUnit,
        hargaJualPerUnit,
        produksiPerHari,
        hariKerjaBulan,
      ];
}
