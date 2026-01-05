import 'package:flutter/material.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../utils/app_utils.dart';

class BepAnalysisCard extends StatelessWidget {
  final BepAnalysis analysis;

  const BepAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Break Even Point (BEP)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (!analysis.isViable) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        analysis.validationMessage ?? 'Model bisnis tidak viable',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildMetricCard(
                icon: Icons.shopping_cart,
                title: 'BEP dalam Unit',
                value: '${analysis.bepUnit} unit',
                subtitle: 'Jumlah produk yang harus dijual untuk balik modal',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                icon: Icons.attach_money,
                title: 'BEP dalam Rupiah',
                value: AppUtils.formatCurrency(analysis.bepRupiah),
                subtitle: 'Total omzet yang dibutuhkan untuk BEP',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                icon: Icons.calendar_today,
                title: 'BEP dalam Waktu',
                value: '${analysis.bepHari} hari (${analysis.bepBulan.toStringAsFixed(1)} bulan)',
                subtitle: 'Waktu yang dibutuhkan untuk mencapai BEP',
                color: Colors.orange,
              ),
              const Divider(height: 24),
              const Text(
                'Detail Analisis:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Contribution Margin',
                AppUtils.formatCurrency(analysis.contributionMargin),
              ),
              _buildInfoRow(
                'Biaya Tetap Bulanan',
                AppUtils.formatCurrency(analysis.biayaTetapBulanan),
              ),
              _buildInfoRow(
                'Biaya Variabel per Unit',
                AppUtils.formatCurrency(analysis.biayaVariabelPerUnit),
              ),
              _buildInfoRow(
                'Harga Jual per Unit',
                AppUtils.formatCurrency(analysis.hargaJualPerUnit),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Insight Bisnis:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Setiap penjualan ${analysis.bepUnit + 1} unit ke atas mulai untung\n'
                      '• Produksi per hari: ${analysis.produksiPerHari} unit\n'
                      '• Target minimum: ${analysis.bepUnit} unit total',
                      style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
