/// Periode komponen biaya
enum PeriodeKomponen {
  harian,
  perBatch,
  mingguan,
  bulanan,
}

extension PeriodeKomponenExtension on PeriodeKomponen {
  String get label {
    switch (this) {
      case PeriodeKomponen.harian:
        return 'Harian';
      case PeriodeKomponen.perBatch:
        return 'Per Batch';
      case PeriodeKomponen.mingguan:
        return 'Mingguan';
      case PeriodeKomponen.bulanan:
        return 'Bulanan';
    }
  }

  int get hariPerPeriode {
    switch (this) {
      case PeriodeKomponen.harian:
        return 1;
      case PeriodeKomponen.perBatch:
        return 0; // tidak berbasis hari
      case PeriodeKomponen.mingguan:
        return 7;
      case PeriodeKomponen.bulanan:
        return 30;
    }
  }
}
