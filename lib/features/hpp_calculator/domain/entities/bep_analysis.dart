import 'package:equatable/equatable.dart';

/// Entity untuk analisis BEP (Break Even Point)
class BepAnalysis extends Equatable {
  final double biayaTetapBulanan;
  final double biayaVariabelPerUnit;
  final double hargaJualPerUnit;
  /// Total produksi per bulan (sudah memperhitungkan jenis produksi)
  final int produksiBulanan;

  const BepAnalysis({
    required this.biayaTetapBulanan,
    required this.biayaVariabelPerUnit,
    required this.hargaJualPerUnit,
    required this.produksiBulanan,
  });

  double get contributionMargin => hargaJualPerUnit - biayaVariabelPerUnit;

  int get bepUnit {
    if (contributionMargin <= 0) return -1;
    return (biayaTetapBulanan / contributionMargin).ceil();
  }

  double get bepRupiah {
    if (bepUnit < 0) return 0;
    return bepUnit * hargaJualPerUnit;
  }

  /// BEP dalam satuan bulan berdasarkan produksi bulanan
  double get bepBulan {
    if (bepUnit < 0 || produksiBulanan <= 0) return -1;
    return bepUnit / produksiBulanan;
  }

  int targetPenjualanUntukProfit(double targetProfit) {
    if (contributionMargin <= 0) return -1;
    return ((biayaTetapBulanan + targetProfit) / contributionMargin).ceil();
  }

  double marginOfSafety(int penjualanAktual) {
    if (bepUnit <= 0 || penjualanAktual <= 0) return 0;
    return ((penjualanAktual - bepUnit) / penjualanAktual) * 100;
  }

  bool get isViable => contributionMargin > 0 && bepUnit > 0;

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
    int? produksiBulanan,
  }) {
    return BepAnalysis(
      biayaTetapBulanan: biayaTetapBulanan ?? this.biayaTetapBulanan,
      biayaVariabelPerUnit: biayaVariabelPerUnit ?? this.biayaVariabelPerUnit,
      hargaJualPerUnit: hargaJualPerUnit ?? this.hargaJualPerUnit,
      produksiBulanan: produksiBulanan ?? this.produksiBulanan,
    );
  }

  @override
  List<Object?> get props => [
        biayaTetapBulanan,
        biayaVariabelPerUnit,
        hargaJualPerUnit,
        produksiBulanan,
      ];
}
