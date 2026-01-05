/// Skala usaha
enum SkalaUsaha { 
  rumahan, 
  sedang, 
  tinggi 
}

extension SkalaUsahaExtension on SkalaUsaha {
  String get label {
    switch (this) {
      case SkalaUsaha.rumahan:
        return 'Usaha Rumahan';
      case SkalaUsaha.sedang:
        return 'Usaha Sedang';
      case SkalaUsaha.tinggi:
        return 'Usaha Tinggi';
    }
  }

  String get deskripsi {
    switch (this) {
      case SkalaUsaha.rumahan:
        return 'Produksi skala kecil, modal terbatas, biasanya dikerjakan sendiri atau keluarga';
      case SkalaUsaha.sedang:
        return 'Memiliki karyawan, tempat produksi khusus, dan kapasitas produksi lebih besar';
      case SkalaUsaha.tinggi:
        return 'Memiliki banyak karyawan, fasilitas produksi lengkap, dan kapasitas produksi besar';
    }
  }

  /// Rekomendasi profit margin berdasarkan skala usaha
  double get rekomendasiProfitMargin {
    switch (this) {
      case SkalaUsaha.rumahan:
        return 30.0;
      case SkalaUsaha.sedang:
        return 40.0;
      case SkalaUsaha.tinggi:
        return 50.0;
    }
  }
}
