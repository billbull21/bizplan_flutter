import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/bep_analysis.dart';

class BepAnalysisCard extends StatelessWidget {
  final BepAnalysis analysis;

  const BepAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (!analysis.isViable) {
      return _buildErrorState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BEP hero metrics
        Row(
          children: [
            Expanded(
              child: _buildBepMetric(
                icon: Icons.shopping_cart_rounded,
                iconColor: AppColors.warning,
                title: 'BEP Unit',
                value: '${analysis.bepUnit}',
                unit: 'unit',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBepMetric(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.primary,
                title: 'BEP Waktu',
                value: analysis.bepBulan >= 0
                    ? analysis.bepBulan.toStringAsFixed(1)
                    : '-',
                unit: 'bulan',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildBepRupiahTile(),
        const SizedBox(height: 12),
        _buildDetailCard(),
        const SizedBox(height: 12),
        _buildInsightCard(),
      ],
    );
  }

  Widget _buildBepMetric({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
  }) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (title == 'BEP Waktu' && analysis.bepBulan >= 0) ...[
            const SizedBox(height: 4),
            Text(
              '≈ ${(analysis.bepBulan * 30).round()} hari',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBepRupiahTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.1),
            AppColors.warning.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.attach_money_rounded,
                color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BEP Omzet',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppUtils.formatCurrency(analysis.bepRupiah),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warning,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Total omzet untuk balik modal',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
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
          const Text(
            'Detail Analisis BEP',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
              'Contribution Margin',
              AppUtils.formatCurrency(analysis.contributionMargin),
              AppColors.accent),
          _buildDetailRow('Biaya Tetap Bulanan',
              AppUtils.formatCurrency(analysis.biayaTetapBulanan), null),
          _buildDetailRow('Biaya Variabel/Unit',
              AppUtils.formatCurrency(analysis.biayaVariabelPerUnit), null),
          _buildDetailRow('Harga Jual/Unit',
              AppUtils.formatCurrency(analysis.hargaJualPerUnit), null),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Business Insight',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Mulai untung setelah menjual ${analysis.bepUnit + 1} unit ke atas\n'
            '• Total produksi/bulan: ${analysis.produksiBulanan} unit\n'
            '• Target minimum bulanan: ${analysis.bepUnit} unit',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              analysis.validationMessage ?? 'Model bisnis tidak viable',
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
