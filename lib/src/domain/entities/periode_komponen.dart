/// Periode komponen biaya (harian, mingguan, bulanan)
enum PeriodeKomponen {
  harian,
  mingguan,
  bulanan,
}

extension PeriodeKomponenExtension on PeriodeKomponen {
  String get label {
    switch (this) {
      case PeriodeKomponen.harian:
        return 'Harian';
      case PeriodeKomponen.mingguan:
        return 'Mingguan';
      case PeriodeKomponen.bulanan:
        return 'Bulanan';
    }
  }

  /// Konversi ke jumlah hari
  int get hariPerPeriode {
    switch (this) {
      case PeriodeKomponen.harian:
        return 1;
      case PeriodeKomponen.mingguan:
        return 7;
      case PeriodeKomponen.bulanan:
        return 30;
    }
  }
}
