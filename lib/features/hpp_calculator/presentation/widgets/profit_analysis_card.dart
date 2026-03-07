import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/profit_analysis.dart';

class ProfitAnalysisCard extends StatelessWidget {
  final ProfitAnalysis analysis;

  const ProfitAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final isProfit = analysis.netProfit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Net profit hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isProfit
                  ? [AppColors.accent, const Color(0xFF059669)]
                  : [AppColors.danger, const Color(0xFFB91C1C)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isProfit
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Net Profit Bulanan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppUtils.formatCurrency(analysis.netProfit),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Net Margin: ${AppUtils.formatPercent(analysis.netProfitMargin)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Gross profit + target
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.primary,
                label: 'Gross Profit',
                value: AppUtils.formatCurrency(analysis.totalGrossProfit),
                sub: 'Margin ${AppUtils.formatPercent(analysis.grossProfitMargin)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.warning,
                label: 'Target Penjualan',
                value: '${analysis.targetPenjualan} unit',
                sub: 'per bulan',
              ),
            ),
          ],
        ),
        if (analysis.investasiAwal != null &&
            analysis.investasiAwal! > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.assessment_rounded,
                  iconColor: AppColors.primary,
                  label: 'ROI',
                  value: AppUtils.formatPercent(analysis.roi),
                  sub: 'Return on Investment',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.accent,
                  label: 'Payback Period',
                  value:
                      '${analysis.paybackPeriodBulan.toStringAsFixed(1)} bln',
                  sub: 'Waktu balik modal',
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _buildDetailCard(),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
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
            'Detail per Unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildRow('Biaya Variabel/Unit', AppUtils.formatCurrency(analysis.biayaVariabelPerUnit), null),
          _buildRow('Harga Jual per Unit',
              AppUtils.formatCurrency(analysis.hargaJualPerUnit), null),
          _buildRow(
            'Gross Profit per Unit',
            AppUtils.formatCurrency(analysis.grossProfitPerUnit),
            AppColors.accent,
          ),
          const Divider(height: 16),
          _buildRow('Biaya Tetap Bulanan',
              AppUtils.formatCurrency(analysis.biayaTetapBulanan), null),
          if (analysis.investasiAwal != null && analysis.investasiAwal! > 0)
            _buildRow('Investasi Awal',
                AppUtils.formatCurrency(analysis.investasiAwal!), null),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color? valueColor) {
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
}
