import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../domain/entities/profit_analysis.dart';
import '../../domain/entities/periode_komponen.dart';

class HppShareView extends StatefulWidget {
  final HppCalculation calculation;
  final BepAnalysis? bepAnalysis;
  final ProfitAnalysis? profitAnalysis;

  const HppShareView({
    super.key,
    required this.calculation,
    this.bepAnalysis,
    this.profitAnalysis,
  });

  @override
  State<HppShareView> createState() => _HppShareViewState();
}

class _HppShareViewState extends State<HppShareView> {
  final _screenshotController = ScreenshotController();
  bool _isSharing = false;

  Future<void> _shareAsImage() async {
    setState(() => _isSharing = true);
    try {
      final Uint8List? image = await _screenshotController.capture(
        pixelRatio: 3.0,
      );
      if (image != null) {
        final XFile xFile;
        if (kIsWeb) {
          xFile = XFile.fromData(
            image,
            mimeType: 'image/png',
            name: 'obizplan_${DateTime.now().millisecondsSinceEpoch}.png',
          );
        } else {
          final dir = await getTemporaryDirectory();
          final path =
              '${dir.path}/obizplan_${DateTime.now().millisecondsSinceEpoch}.png';
          await File(path).writeAsBytes(image);
          xFile = XFile(path);
        }
        await Share.shareXFiles(
          [xFile],
          text: 'Hasil HPP - ${widget.calculation.namaProduk} | Obizplan',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal share: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bagikan Hasil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareAsImage,
              icon: _isSharing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(_isSharing ? 'Saving...' : 'Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Screenshot(
          controller: _screenshotController,
          child: _buildShareCard(),
        ),
      ),
    );
  }

  Widget _buildShareCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'OBIZPLAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('dd MMM yyyy', 'id_ID')
                          .format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Laporan HPP',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.calculation.namaProduk,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildHeaderMetric(
                      label: 'HPP/Unit',
                      value: AppUtils.formatCurrency(
                          widget.calculation.hppPerUnit),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildHeaderMetric(
                      label: 'Harga Jual',
                      value: AppUtils.formatCurrency(
                          widget.calculation.hargaJualPerUnit),
                      isAccent: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  icon: Icons.calculate_rounded,
                  title: 'Harga Pokok Produksi',
                  rows: [
                    _buildRow('Total Biaya/Bulan',
                        AppUtils.formatCurrency(widget.calculation.totalBiayaBulanan)),
                    _buildRow('Produksi/Bulan',
                        '${widget.calculation.settingProduksi.totalProduksiBulan} unit'),
                    _buildRow('HPP per Unit',
                        AppUtils.formatCurrency(widget.calculation.hppPerUnit),
                        highlighted: true),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.trending_up_rounded,
                  title: 'Harga Jual & Profit',
                  rows: [
                    _buildRow('Profit Margin',
                        '${widget.calculation.profitMargin.toStringAsFixed(1)}%'),
                    _buildRow('Profit/Unit',
                        AppUtils.formatCurrency(widget.calculation.profitPerUnit)),
                    _buildRow('Harga Jual/Unit',
                        AppUtils.formatCurrency(
                            widget.calculation.hargaJualPerUnit),
                        highlighted: true,
                        accentColor: AppColors.accent),
                  ],
                ),
                if (widget.bepAnalysis != null) ...[
                  const SizedBox(height: 20),
                  _buildSection(
                    icon: Icons.analytics_rounded,
                    title: 'Break Even Point',
                    rows: [
                      _buildRow('BEP Unit',
                          '${widget.bepAnalysis!.bepUnit} unit/bulan'),
                      _buildRow('BEP Omzet',
                          AppUtils.formatCurrency(widget.bepAnalysis!.bepRupiah)),
                      _buildRow('Waktu BEP',
                          '${widget.bepAnalysis!.bepBulan.toStringAsFixed(1)} bulan'),
                    ],
                  ),
                ],
                if (widget.profitAnalysis != null) ...[
                  const SizedBox(height: 20),
                  _buildSection(
                    icon: Icons.bar_chart_rounded,
                    title: 'Analisis Profit',
                    rows: [
                      _buildRow('Target Penjualan',
                          '${widget.profitAnalysis!.targetPenjualan} unit/bln'),
                      _buildRow('Gross Profit',
                          AppUtils.formatCurrency(
                              widget.profitAnalysis!.totalGrossProfit)),
                      _buildRow('Net Profit',
                          AppUtils.formatCurrency(widget.profitAnalysis!.netProfit),
                          highlighted: true,
                          accentColor: widget.profitAnalysis!.netProfit >= 0
                              ? AppColors.accent
                              : AppColors.danger),
                      if (widget.profitAnalysis!.investasiAwal != null &&
                          widget.profitAnalysis!.investasiAwal! > 0)
                        _buildRow('ROI',
                            AppUtils.formatPercent(widget.profitAnalysis!.roi)),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                _buildSection(
                  icon: Icons.receipt_long_rounded,
                  title: 'Rincian Komponen Biaya',
                  rows: widget.calculation.komponenBiaya.map((k) {
                    return _buildKomponenRow(k.nama, k.nilai, k.periode.label,
                        k.isTetap);
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Footer
                Center(
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Dibuat dengan Obizplan',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Kalkulator HPP untuk UMKM Indonesia',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(
      {required String label, required String value, bool isAccent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isAccent
                ? AppColors.accentLight
                : Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isAccent ? AppColors.accentLight : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool highlighted = false,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.primary;
    return Container(
      margin: highlighted ? const EdgeInsets.only(top: 8) : EdgeInsets.zero,
      padding: highlighted ? const EdgeInsets.all(10) : const EdgeInsets.symmetric(vertical: 4),
      decoration: highlighted
          ? BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: highlighted ? 13 : 13,
              color: highlighted ? color : AppColors.textSecondary,
              fontWeight:
                  highlighted ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlighted ? 15 : 13,
              fontWeight: FontWeight.w700,
              color: highlighted ? color : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKomponenRow(
      String nama, double nilai, String periode, bool isTetap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nama,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Text(
            AppUtils.formatCurrency(nilai),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isTetap
                  ? AppColors.warningContainer
                  : AppColors.accentContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              periode,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color:
                    isTetap ? AppColors.warning : AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
