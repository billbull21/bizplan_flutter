import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../domain/entities/profit_analysis.dart';
import '../../domain/entities/jenis_produksi.dart';
import '../../domain/entities/skala_usaha.dart';
import '../../domain/entities/periode_komponen.dart';

class AiInsightService {
  final _fmt = NumberFormat('#,###', 'id_ID');

  /// Debug  → local proxy (node scripts/proxy.js)
  /// Release → Netlify Function proxy
  /// API key tidak pernah ada di Flutter.
  String get _endpoint {
    if (kDebugMode) return ApiConfig.localProxyUrl;
    return ApiConfig.netlifyFunctionPath;
  }

  Dio _buildDio() {
    if (kDebugMode) {
      return Dio(BaseOptions(
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ));
    }
    return Dio(BaseOptions(
      baseUrl: Uri.base.origin,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  Future<AiInsight> analyze({
    required HppCalculation calculation,
    BepAnalysis? bepAnalysis,
    ProfitAnalysis? profitAnalysis,
  }) async {
    final dio = _buildDio();
    final prompt = _buildPrompt(calculation, bepAnalysis, profitAnalysis);

    final response = await dio.post(_endpoint, data: {
      'model': ApiConfig.openAiModel,
      'temperature': 0.2,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content':
              'Kamu adalah konsultan bisnis UMKM Indonesia. '
              'Tugasmu HANYA menginterpretasi data yang sudah disediakan — '
              'JANGAN hitung ulang, JANGAN asumsikan angka yang tidak ada di data. '
              'Semua angka bulanan sudah dihitung oleh sistem. '
              'Berikan analisis praktis dalam Bahasa Indonesia. '
              'Selalu respond dalam format JSON yang valid.',
        },
        {'role': 'user', 'content': prompt},
      ],
    });

    final content =
        response.data['choices'][0]['message']['content'] as String;
    final json = jsonDecode(content) as Map<String, dynamic>;
    return AiInsight.fromJson(json);
  }

  String _buildPrompt(
    HppCalculation calc,
    BepAnalysis? bep,
    ProfitAnalysis? profit,
  ) {
    String rp(double v) => 'Rp ${_fmt.format(v.toInt())}';
    final isBatch = calc.settingProduksi.jenisProduksi == JenisProduksi.batch;
    final hariKerja = calc.settingProduksi.hariKerjaBulan;
    final frekuensiBatch = calc.settingProduksi.frekuensiBatchPerBulan ?? 1;

    // Pre-hitung biaya per komponen ke bulanan (sama persis dengan logika app)
    double totalVariabelBulanan = 0;
    double totalTetapBulanan = 0;
    final komponenLines = <String>[];
    for (final k in calc.komponenBiaya) {
      final bulanan = k.hitungBiayaBulanan(
        hariKerjaBulan: hariKerja,
        frekuensiBatchPerBulan: frekuensiBatch,
      );
      final tipe = k.isTetap ? 'TETAP' : 'VARIABEL';
      // Jelaskan perhitungan agar AI tidak menghitung ulang
      String kalkulasi;
      switch (k.periode) {
        case PeriodeKomponen.harian:
          kalkulasi =
              '${rp(k.nilai)} × $hariKerja hari = ${rp(bulanan)}/bulan';
          break;
        case PeriodeKomponen.perBatch:
          kalkulasi =
              '${rp(k.nilai)} × ${frekuensiBatch}x batch = ${rp(bulanan)}/bulan';
          break;
        case PeriodeKomponen.mingguan:
          kalkulasi = '${rp(k.nilai)} × 4.33 minggu = ${rp(bulanan)}/bulan';
          break;
        case PeriodeKomponen.bulanan:
          kalkulasi = '${rp(bulanan)}/bulan';
          break;
      }
      if (k.isTetap) {
        totalTetapBulanan += bulanan;
      } else {
        totalVariabelBulanan += bulanan;
      }
      komponenLines.add('  • ${k.nama} [$tipe]: $kalkulasi');
    }

    final totalProduksi = calc.settingProduksi.totalProduksiBulan;
    final biayaVariabelPerUnit = totalProduksi > 0
        ? totalVariabelBulanan / totalProduksi
        : 0.0;
    final rekomendasiMargin = calc.skalaUsaha.rekomendasiProfitMargin;

    final sb = StringBuffer();
    sb.writeln('DATA BISNIS (semua angka sudah dihitung oleh sistem — gunakan apa adanya):');
    sb.writeln();

    // Konteks produksi
    sb.writeln('## PROFIL USAHA');
    sb.writeln('Produk: ${calc.namaProduk}');
    sb.writeln('Skala: ${calc.skalaUsaha.label} (rekomendasi margin: ${rekomendasiMargin.toStringAsFixed(0)}%)');
    if (isBatch) {
      sb.writeln('Mode: Batch — ${calc.settingProduksi.jumlahProduksiBatch} unit/batch × ${frekuensiBatch}x/bulan = $totalProduksi unit/bulan');
    } else {
      sb.writeln('Mode: Harian — ${calc.settingProduksi.jumlahProduksiPerHari} unit/hari × $hariKerja hari = $totalProduksi unit/bulan');
    }
    sb.writeln();

    // Biaya sudah dikonversi ke bulanan
    sb.writeln('## RINCIAN BIAYA (sudah dikonversi ke bulanan)');
    for (final line in komponenLines) {
      sb.writeln(line);
    }
    sb.writeln('  ─────────────────────────────────────');
    sb.writeln('  Total Biaya Variabel/Bulan : ${rp(totalVariabelBulanan)}');
    sb.writeln('  Total Biaya Tetap/Bulan    : ${rp(totalTetapBulanan)}');
    sb.writeln('  Total Biaya/Bulan          : ${rp(calc.totalBiayaBulanan)}');
    sb.writeln();

    // Hasil HPP
    sb.writeln('## HASIL HPP');
    sb.writeln('HPP per Unit             : ${rp(calc.hppPerUnit)}');
    sb.writeln('Biaya Variabel per Unit  : ${rp(biayaVariabelPerUnit)}');
    sb.writeln('Profit Margin Dipilih    : ${calc.profitMargin.toStringAsFixed(1)}% (rekomendasi: ${rekomendasiMargin.toStringAsFixed(0)}%)');
    sb.writeln('Harga Jual per Unit      : ${rp(calc.hargaJualPerUnit)}');
    sb.writeln('Profit per Unit          : ${rp(calc.profitPerUnit)}');
    sb.writeln('Total Profit/Bulan       : ${rp(calc.totalProfitBulanan)}');
    sb.writeln();

    if (bep != null) {
      sb.writeln('## BEP (BREAK EVEN POINT)');
      sb.writeln('Contribution Margin/Unit : ${rp(bep.contributionMargin)}');
      sb.writeln('BEP                      : ${bep.bepUnit} unit/bulan');
      sb.writeln('Kapasitas produksi       : $totalProduksi unit/bulan');
      sb.writeln('Selisih (kapasitas-BEP)  : ${totalProduksi - bep.bepUnit} unit/bulan');
      sb.writeln('Waktu BEP                : ${bep.bepBulan.toStringAsFixed(1)} bulan');
      sb.writeln();
    }

    if (profit != null) {
      sb.writeln('## ANALISIS PROFIT');
      sb.writeln('Target Penjualan         : ${profit.targetPenjualan} unit/bulan');
      sb.writeln('Gross Profit             : ${rp(profit.totalGrossProfit)}');
      sb.writeln('Net Profit               : ${rp(profit.netProfit)}');
      sb.writeln('Net Profit Margin        : ${profit.netProfitMargin.toStringAsFixed(1)}%');
      if (profit.investasiAwal != null && profit.investasiAwal! > 0) {
        sb.writeln('ROI                      : ${profit.roi.toStringAsFixed(1)}%');
        sb.writeln('Payback Period           : ${profit.paybackPeriodBulan.toStringAsFixed(1)} bulan');
      }
      sb.writeln();
    }

    sb.writeln('## INSTRUKSI ANALISIS');
    sb.writeln('Buat TEPAT 5 insight dengan kategori berikut (satu insight per kategori, urutan tetap):');
    sb.writeln('1. kategori "biaya"      — evaluasi struktur & efisiensi biaya (variabel vs tetap, komponen terbesar)');
    sb.writeln('2. kategori "harga"      — evaluasi harga jual vs HPP, margin vs rekomendasi skala usaha');
    sb.writeln('3. kategori "produksi"   — evaluasi volume produksi, ${isBatch ? "frekuensi batch" : "hari kerja"}, kapasitas vs BEP');
    sb.writeln('4. kategori "profit"     — evaluasi kelayakan profit bulanan, risiko rugi, proyeksi');
    sb.writeln('5. kategori "umum"       — satu rekomendasi strategis terpenting untuk usaha ini');
    sb.writeln();
    sb.writeln('Format JSON (JANGAN tambah atau kurangi properti):');
    sb.writeln('''{
  "skor_kesehatan": <0-100, hitung dari: margin vs rekomendasi (30%) + profit positif (30%) + BEP tercapai (20%) + struktur biaya wajar (20%)>,
  "ringkasan": "<1-2 kalimat ringkasan kondisi bisnis, sebut angka kunci>",
  "insights": [
    {
      "kategori": "<biaya|harga|produksi|profit|umum>",
      "level": "<success|warning|danger|info>",
      "judul": "<max 7 kata>",
      "detail": "<gunakan angka dari data di atas, jangan hitung ulang>",
      "rekomendasi": "<langkah konkret dan spesifik>"
    }
  ]
}''');

    return sb.toString();
  }
}
