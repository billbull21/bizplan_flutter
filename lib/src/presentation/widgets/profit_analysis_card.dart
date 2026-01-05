import 'package:flutter/material.dart';
import '../../domain/entities/profit_analysis.dart';
import '../../utils/app_utils.dart';

class ProfitAnalysisCard extends StatelessWidget {
  final ProfitAnalysis analysis;

  const ProfitAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Analisis Profit',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildMetricCard(
              icon: Icons.account_balance_wallet,
              title: 'Gross Profit',
              value: AppUtils.formatCurrency(analysis.totalGrossProfit),
              subtitle: 'Margin: ${analysis.grossProfitMargin.toStringAsFixed(1)}%',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              icon: Icons.monetization_on,
              title: 'Net Profit',
              value: AppUtils.formatCurrency(analysis.netProfit),
              subtitle: 'Setelah biaya tetap - Margin: ${analysis.netProfitMargin.toStringAsFixed(1)}%',
              color: analysis.netProfit >= 0 ? Colors.green : Colors.red,
            ),
            if (analysis.investasiAwal != null && analysis.investasiAwal! > 0) ...[
              const SizedBox(height: 12),
              _buildMetricCard(
                icon: Icons.assessment,
                title: 'ROI (Return on Investment)',
                value: '${analysis.roi.toStringAsFixed(1)}%',
                subtitle: 'Investasi: ${AppUtils.formatCurrency(analysis.investasiAwal!)}',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                icon: Icons.access_time,
                title: 'Payback Period',
                value: '${analysis.paybackPeriodBulan.toStringAsFixed(1)} bulan',
                subtitle: 'Waktu untuk balik modal dari investasi awal',
                color: Colors.purple,
              ),
            ],
            const Divider(height: 24),
            const Text(
              'Detail per Unit:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('HPP per Unit', AppUtils.formatCurrency(analysis.hppPerUnit)),
            _buildInfoRow(
              'Harga Jual per Unit',
              AppUtils.formatCurrency(analysis.hargaJualPerUnit),
            ),
            _buildInfoRow(
              'Gross Profit per Unit',
              AppUtils.formatCurrency(analysis.grossProfitPerUnit),
              color: Colors.green.shade700,
            ),
            const Divider(height: 24),
            const Text(
              'Target & Proyeksi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Target Penjualan', '${analysis.targetPenjualan} unit'),
            _buildInfoRow('Jumlah Produksi', '${analysis.jumlahProduksi} unit'),
            _buildInfoRow(
              'Biaya Tetap Bulanan',
              AppUtils.formatCurrency(analysis.biayaTetapBulanan),
            ),
            const SizedBox(height: 16),
            _buildInsightBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    // Convert Color to MaterialColor if needed
    final borderColor = color is MaterialColor ? color.shade300 : color.withOpacity(0.3);
    final bgColor = color is MaterialColor ? color.shade100 : color.withOpacity(0.1);
    final iconColor = color is MaterialColor ? color.shade700 : color;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBox() {
    final isProfit = analysis.netProfit >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isProfit ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProfit ? Icons.check_circle : Icons.warning,
                color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                isProfit ? 'Bisnis Profitable! 🎉' : 'Perlu Penyesuaian ⚠️',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isProfit
                ? '• Target penjualan ${analysis.targetPenjualan} unit menghasilkan net profit ${AppUtils.formatCurrency(analysis.netProfit)}\n'
                    '• Gross profit margin ${analysis.grossProfitMargin.toStringAsFixed(1)}% sangat baik\n'
                    '• Pertahankan efisiensi produksi untuk hasil maksimal'
                : '• Net profit negatif: ${AppUtils.formatCurrency(analysis.netProfit.abs())}\n'
                    '• Pertimbangkan: naikkan harga jual, tingkatkan penjualan, atau kurangi biaya tetap\n'
                    '• Analisis ulang struktur biaya untuk profitabilitas',
            style: TextStyle(
              fontSize: 13,
              color: isProfit ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
