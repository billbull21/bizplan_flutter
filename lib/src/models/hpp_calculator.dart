enum SkalaUsaha { rumahan, sedang, tinggi }

class HppCalculator {
  String namaProduk = '';
  double bahanBaku = 0;
  double tenagaKerja = 0;
  double overheadPabrik = 0;
  double biayaLain = 0;
  int jumlahProduksi = 1;
  SkalaUsaha skalaUsaha = SkalaUsaha.rumahan;
  double profitMargin = 30; // Default profit margin 30%
  
  HppCalculator copy() {
    final calculator = HppCalculator();
    calculator.namaProduk = namaProduk;
    calculator.jumlahProduksi = jumlahProduksi;
    calculator.bahanBaku = bahanBaku;
    calculator.tenagaKerja = tenagaKerja;
    calculator.overheadPabrik = overheadPabrik;
    calculator.biayaLain = biayaLain;
    calculator.profitMargin = profitMargin;
    calculator.skalaUsaha = skalaUsaha;
    return calculator;
  }

  HppCalculator({
    this.bahanBaku = 0,
    this.tenagaKerja = 0,
    this.overheadPabrik = 0,
    this.biayaLain = 0,
    this.jumlahProduksi = 1,
    this.skalaUsaha = SkalaUsaha.rumahan,
    this.profitMargin = 30,
  });

  double get totalBiaya => bahanBaku + tenagaKerja + overheadPabrik + biayaLain;
  
  double get hppPerUnit {
    if (jumlahProduksi <= 0) return 0;
    return totalBiaya / jumlahProduksi;
  }

  // Harga jual berdasarkan HPP + profit margin
  double get hargaJualPerUnit {
    return hppPerUnit * (1 + (profitMargin / 100));
  }

  // Profit per unit
  double get profitPerUnit {
    return hargaJualPerUnit - hppPerUnit;
  }

  // Total profit
  double get totalProfit {
    return profitPerUnit * jumlahProduksi;
  }

  // Rekomendasi profit margin berdasarkan skala usaha
  double get rekomendasiProfitMargin {
    switch (skalaUsaha) {
      case SkalaUsaha.rumahan:
        return 30; // 30% untuk usaha rumahan
      case SkalaUsaha.sedang:
        return 40; // 40% untuk usaha sedang
      case SkalaUsaha.tinggi:
        return 50; // 50% untuk usaha tinggi
    }
  }

  // Informasi tambahan untuk setiap field
  static Map<String, String> get informasiBahanBaku {
    return {
      'title': 'Biaya Bahan Baku',
      'description': 'Biaya untuk semua bahan mentah yang digunakan dalam produksi. Termasuk bahan utama dan bahan pendukung yang menjadi bagian dari produk akhir.',
      'contoh': 'Contoh: Kain untuk pakaian, tepung untuk kue, kayu untuk furnitur.',
      'tips': 'Tip: Catat semua bahan yang digunakan dan hitung biaya per unit produksi.'
    };
  }

  static Map<String, String> get informasiTenagaKerja {
    return {
      'title': 'Biaya Tenaga Kerja',
      'description': 'Upah yang dibayarkan kepada pekerja yang terlibat langsung dalam proses produksi.',
      'contoh': 'Contoh: Upah penjahit, tukang kayu, koki, atau operator mesin.',
      'tips': 'Tip: Hitung berdasarkan jam kerja atau jumlah produk yang dihasilkan.'
    };
  }

  static Map<String, String> get informasiOverheadPabrik {
    return {
      'title': 'Biaya Overhead Pabrik',
      'description': 'Biaya tidak langsung yang diperlukan untuk mendukung proses produksi.',
      'contoh': 'Contoh: Listrik, air, sewa tempat produksi, penyusutan mesin, dan perawatan peralatan.',
      'tips': 'Tip: Alokasikan biaya overhead berdasarkan persentase dari total produksi.'
    };
  }

  static Map<String, String> get informasiBiayaLain {
    return {
      'title': 'Biaya Lain-lain',
      'description': 'Biaya tambahan yang tidak termasuk dalam kategori di atas namun diperlukan untuk produksi.',
      'contoh': 'Contoh: Biaya pengiriman bahan baku, biaya kemasan, biaya inspeksi kualitas.',
      'tips': 'Tip: Jangan lupakan biaya-biaya kecil yang bisa terakumulasi menjadi signifikan.'
    };
  }

  static Map<String, String> get informasiJumlahProduksi {
    return {
      'title': 'Jumlah Produksi',
      'description': 'Total unit produk yang dihasilkan dalam satu siklus produksi.',
      'contoh': 'Contoh: 100 potong pakaian, 50 kg kue, 25 unit furnitur.',
      'tips': 'Tip: Semakin besar jumlah produksi, biasanya semakin rendah HPP per unit.'
    };
  }

  static Map<String, String> get informasiSkalaUsaha {
    return {
      'title': 'Skala Usaha',
      'description': 'Ukuran atau kapasitas bisnis yang menentukan rekomendasi profit margin.',
      'rumahan': 'Usaha Rumahan: Produksi skala kecil, modal terbatas, biasanya dikerjakan sendiri atau keluarga.',
      'sedang': 'Usaha Sedang: Memiliki karyawan, tempat produksi khusus, dan kapasitas produksi lebih besar.',
      'tinggi': 'Usaha Tinggi: Memiliki banyak karyawan, fasilitas produksi lengkap, dan kapasitas produksi besar.'
    };
  }

  static Map<String, String> get informasiProfitMargin {
    return {
      'title': 'Profit Margin',
      'description': 'Persentase keuntungan yang ditambahkan di atas HPP untuk menentukan harga jual.',
      'rumahan': 'Usaha Rumahan: Disarankan 20-30% untuk tetap kompetitif namun menguntungkan.',
      'sedang': 'Usaha Sedang: Disarankan 30-40% untuk menutupi biaya operasional yang lebih tinggi.',
      'tinggi': 'Usaha Tinggi: Disarankan 40-50% untuk investasi pengembangan dan ekspansi usaha.'
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'bahanBaku': bahanBaku,
      'tenagaKerja': tenagaKerja,
      'overheadPabrik': overheadPabrik,
      'biayaLain': biayaLain,
      'jumlahProduksi': jumlahProduksi,
      'skalaUsaha': skalaUsaha.index,
      'profitMargin': profitMargin,
      'totalBiaya': totalBiaya,
      'hppPerUnit': hppPerUnit,
      'hargaJualPerUnit': hargaJualPerUnit,
    };
  }

  factory HppCalculator.fromJson(Map<String, dynamic> json) {
    return HppCalculator(
      bahanBaku: json['bahanBaku'] ?? 0,
      tenagaKerja: json['tenagaKerja'] ?? 0,
      overheadPabrik: json['overheadPabrik'] ?? 0,
      biayaLain: json['biayaLain'] ?? 0,
      jumlahProduksi: json['jumlahProduksi'] ?? 1,
      skalaUsaha: SkalaUsaha.values[json['skalaUsaha'] ?? 0],
      profitMargin: json['profitMargin'] ?? 30,
    );
  }
}