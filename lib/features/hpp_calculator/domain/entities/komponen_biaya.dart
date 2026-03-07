import 'package:equatable/equatable.dart';
import 'periode_komponen.dart';

/// Entity untuk komponen biaya individual
class KomponenBiaya extends Equatable {
  final String id;
  final String nama;
  final double nilai;
  final PeriodeKomponen periode;
  final bool isTetap;
  final String? keterangan;

  const KomponenBiaya({
    required this.id,
    required this.nama,
    required this.nilai,
    required this.periode,
    this.isTetap = false,
    this.keterangan,
  });

  /// Konversi nilai komponen ke biaya BULANAN
  double hitungBiayaBulanan({
    int hariKerjaBulan = 25,
    int frekuensiBatchPerBulan = 1,
  }) {
    switch (periode) {
      case PeriodeKomponen.harian:
        return nilai * hariKerjaBulan;
      case PeriodeKomponen.perBatch:
        return nilai * frekuensiBatchPerBulan;
      case PeriodeKomponen.mingguan:
        // rata-rata 52 minggu / 12 bulan ≈ 4.33
        return nilai * (52.0 / 12.0);
      case PeriodeKomponen.bulanan:
        return nilai;
    }
  }

  /// Hitung biaya per unit produksi berdasarkan total produksi bulanan
  double hitungBiayaPerUnit(
    int totalProduksiBulan, {
    int hariKerjaBulan = 25,
    int frekuensiBatchPerBulan = 1,
  }) {
    if (totalProduksiBulan <= 0) return 0;
    return hitungBiayaBulanan(
          hariKerjaBulan: hariKerjaBulan,
          frekuensiBatchPerBulan: frekuensiBatchPerBulan,
        ) /
        totalProduksiBulan;
  }

  double hitungTotalBiaya(
    int totalProduksiBulan, {
    int hariKerjaBulan = 25,
    int frekuensiBatchPerBulan = 1,
  }) {
    return hitungBiayaBulanan(
      hariKerjaBulan: hariKerjaBulan,
      frekuensiBatchPerBulan: frekuensiBatchPerBulan,
    );
  }

  KomponenBiaya copyWith({
    String? id,
    String? nama,
    double? nilai,
    PeriodeKomponen? periode,
    bool? isTetap,
    String? keterangan,
  }) {
    return KomponenBiaya(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nilai: nilai ?? this.nilai,
      periode: periode ?? this.periode,
      isTetap: isTetap ?? this.isTetap,
      keterangan: keterangan ?? this.keterangan,
    );
  }

  @override
  List<Object?> get props => [id, nama, nilai, periode, isTetap, keterangan];
}
