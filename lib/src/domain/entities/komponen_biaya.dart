import 'package:equatable/equatable.dart';
import 'periode_komponen.dart';

/// Entity untuk komponen biaya individual
class KomponenBiaya extends Equatable {
  final String id;
  final String nama;
  final double nilai;
  final PeriodeKomponen periode;
  final bool isTetap; // true = biaya tetap, false = variabel
  final String? keterangan;

  const KomponenBiaya({
    required this.id,
    required this.nama,
    required this.nilai,
    required this.periode,
    this.isTetap = false,
    this.keterangan,
  });

  /// Hitung biaya per unit produksi
  /// 
  /// [jumlahProduksi] - jumlah unit yang diproduksi dalam satu periode
  /// [hariProduksiPerBulan] - berapa hari produksi dalam sebulan (default 25)
  double hitungBiayaPerUnit(int jumlahProduksi, {int hariProduksiPerBulan = 25}) {
    if (jumlahProduksi <= 0) return 0;

    switch (periode) {
      case PeriodeKomponen.harian:
        // Biaya harian langsung dibagi jumlah produksi
        return nilai / jumlahProduksi;
      
      case PeriodeKomponen.mingguan:
        // Biaya mingguan dikonversi ke harian dulu
        final biayaHarian = nilai / 7;
        return biayaHarian / jumlahProduksi;
      
      case PeriodeKomponen.bulanan:
        // Biaya bulanan dikonversi ke harian berdasarkan hari produksi
        final biayaHarian = nilai / hariProduksiPerBulan;
        return biayaHarian / jumlahProduksi;
    }
  }

  /// Hitung total biaya untuk jumlah produksi tertentu
  double hitungTotalBiaya(int jumlahProduksi, {int hariProduksiPerBulan = 25}) {
    return hitungBiayaPerUnit(jumlahProduksi, hariProduksiPerBulan: hariProduksiPerBulan) * jumlahProduksi;
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
