/// Level keseriusan insight
enum InsightLevel { success, warning, danger, info }

/// Kategori insight
enum InsightKategori { biaya, harga, produksi, profit, umum }

/// Satu item insight dari AI
class InsightItem {
  final InsightKategori kategori;
  final InsightLevel level;
  final String judul;
  final String detail;
  final String rekomendasi;

  const InsightItem({
    required this.kategori,
    required this.level,
    required this.judul,
    required this.detail,
    required this.rekomendasi,
  });

  factory InsightItem.fromJson(Map<String, dynamic> json) {
    return InsightItem(
      kategori: _parseKategori(json['kategori'] as String? ?? 'umum'),
      level: _parseLevel(json['level'] as String? ?? 'info'),
      judul: json['judul'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      rekomendasi: json['rekomendasi'] as String? ?? '',
    );
  }

  static InsightKategori _parseKategori(String v) {
    switch (v) {
      case 'biaya':
        return InsightKategori.biaya;
      case 'harga':
        return InsightKategori.harga;
      case 'produksi':
        return InsightKategori.produksi;
      case 'profit':
        return InsightKategori.profit;
      default:
        return InsightKategori.umum;
    }
  }

  static InsightLevel _parseLevel(String v) {
    switch (v) {
      case 'success':
        return InsightLevel.success;
      case 'warning':
        return InsightLevel.warning;
      case 'danger':
        return InsightLevel.danger;
      default:
        return InsightLevel.info;
    }
  }
}

/// Hasil analisis AI secara keseluruhan
class AiInsight {
  final int skorKesehatan; // 0-100
  final String ringkasan;
  final List<InsightItem> insights;

  const AiInsight({
    required this.skorKesehatan,
    required this.ringkasan,
    required this.insights,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      skorKesehatan:
          (json['skor_kesehatan'] as num?)?.toInt().clamp(0, 100) ?? 50,
      ringkasan: json['ringkasan'] as String? ?? '',
      insights: (json['insights'] as List<dynamic>? ?? [])
          .map((e) => InsightItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
