/// Jenis/kategori produksi
enum JenisProduksi {
  harian,
  batch,
  bulanan,
  custom,
}

extension JenisProduksiExtension on JenisProduksi {
  String get label {
    switch (this) {
      case JenisProduksi.harian:
        return 'Produksi Harian';
      case JenisProduksi.batch:
        return 'Produksi Batch';
      case JenisProduksi.bulanan:
        return 'Produksi Bulanan';
      case JenisProduksi.custom:
        return 'Custom';
    }
  }

  String get deskripsi {
    switch (this) {
      case JenisProduksi.harian:
        return 'Produksi setiap hari (cocok untuk makanan, minuman, produk segar)';
      case JenisProduksi.batch:
        return 'Produksi berkala dalam jumlah besar (cocok untuk fashion, handicraft)';
      case JenisProduksi.bulanan:
        return 'Target produksi per bulan (cocok untuk manufaktur, produk industri)';
      case JenisProduksi.custom:
        return 'Atur sendiri sesuai kebutuhan';
    }
  }

  /// Default hari kerja per bulan untuk jenis produksi
  int get defaultHariKerjaBulan {
    switch (this) {
      case JenisProduksi.harian:
        return 30; // Produksi setiap hari
      case JenisProduksi.batch:
        return 20; // Produksi berkala
      case JenisProduksi.bulanan:
        return 25; // Hari kerja normal
      case JenisProduksi.custom:
        return 25;
    }
  }
}
