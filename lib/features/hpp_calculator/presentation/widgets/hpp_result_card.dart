import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/jenis_produksi.dart';

class HppResultCard extends StatelessWidget {
  final HppCalculation calculation;

  const HppResultCard({super.key, required this.calculation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hasil HPP',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          calculation.namaProduk,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildHeroMetric(
                      label: 'HPP per Unit',
                      value: AppUtils.formatCurrency(calculation.hppPerUnit),
                      sublabel: 'Harga Pokok Produksi',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 56,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _buildHeroMetric(
                      label: 'Harga Jual',
                      value:
                          AppUtils.formatCurrency(calculation.hargaJualPerUnit),
                      sublabel:
                          'Margin ${calculation.profitMargin.toStringAsFixed(0)}%',
                      isAccent: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Profit metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.accent,
                label: 'Profit/Unit',
                value: AppUtils.formatCurrency(calculation.profitPerUnit),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                label: 'Est. Profit Bulanan',
                value: AppUtils.formatCurrency(calculation.totalProfitBulanan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Breakdown card
        _buildBreakdownCard(),
      ],
    );
  }

  Widget _buildHeroMetric({
    required String label,
    required String value,
    required String sublabel,
    bool isAccent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
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
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isAccent ? AppColors.accentLight : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    final breakdown = calculation.breakdownBiayaByPeriode;
    final nonZeroEntries =
        breakdown.entries.where((e) => e.value > 0).toList();

    if (nonZeroEntries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Breakdown Biaya',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...nonZeroEntries.map((entry) {
            final totalBiaya = breakdown.values.fold(0.0, (a, b) => a + b);
            final persen =
                totalBiaya > 0 ? (entry.value / totalBiaya) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            AppUtils.formatCurrency(entry.value),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${persen.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: persen / 100,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Biaya Produksi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                AppUtils.formatCurrency(calculation.totalBiaya),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _buildProduksiInfoText(calculation),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildProduksiInfoText(HppCalculation calculation) {
    final sp = calculation.settingProduksi;
    switch (sp.jenisProduksi) {
      case JenisProduksi.batch:
        return '${sp.jumlahProduksiBatch ?? 0} unit/batch × '
            '${sp.frekuensiBatchPerBulan ?? 0} batch/bulan = '
            '${sp.totalProduksiBulan} unit/bulan';
      case JenisProduksi.harian:
        return '${sp.jumlahProduksiPerHari} unit/hari × '
            '${sp.hariKerjaBulan} hari = '
            '${sp.totalProduksiBulan} unit/bulan';
      case JenisProduksi.bulanan:
      case JenisProduksi.custom:
        return 'Total produksi: ${sp.totalProduksiBulan} unit/bulan';
    }
  }
}
