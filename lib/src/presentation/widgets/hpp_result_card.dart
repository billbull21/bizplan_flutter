import 'package:flutter/material.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/jenis_produksi.dart';
import '../../utils/app_utils.dart';

class HppResultCard extends StatelessWidget {
  final HppCalculation calculation;

  const HppResultCard({super.key, required this.calculation});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Hasil Perhitungan HPP',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildInfoRow('Nama Produk', calculation.namaProduk, isBold: true),
            _buildInfoRow(
              'Jenis Produksi',
              calculation.settingProduksi.jenisProduksi.label,
            ),
            const Divider(height: 24),
            const Text(
              'Breakdown Biaya per Periode:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...calculation.breakdownBiayaByPeriode.entries.map((entry) {
              if (entry.value > 0) {
                return _buildInfoRow(
                  'Biaya ${entry.key.toUpperCase()}',
                  AppUtils.formatCurrency(entry.value),
                  color: Colors.blue.shade700,
                );
              }
              return const SizedBox.shrink();
            }),
            const Divider(height: 24),
            _buildResultRow(
              'Total Biaya Produksi',
              AppUtils.formatCurrency(calculation.totalBiaya),
            ),
            _buildResultRow(
              '💰 HPP per Unit',
              AppUtils.formatCurrency(calculation.hppPerUnit),
              isHighlighted: true,
              color: Colors.blue.shade700,
            ),
            const Divider(height: 24),
            const Text(
              'Analisis Harga & Profit:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Profit Margin',
              '${calculation.profitMargin}%',
            ),
            _buildInfoRow(
              'Profit per Unit',
              AppUtils.formatCurrency(calculation.profitPerUnit),
              color: Colors.green.shade700,
            ),
            _buildResultRow(
              '🏷️ Harga Jual per Unit',
              AppUtils.formatCurrency(calculation.hargaJualPerUnit),
              isHighlighted: true,
              color: Colors.green.shade700,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Profit Harian',
              AppUtils.formatCurrency(calculation.totalProfitHarian),
              color: Colors.green,
            ),
            _buildInfoRow(
              'Profit Bulanan (estimasi)',
              AppUtils.formatCurrency(calculation.totalProfitBulanan),
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Produksi: ${calculation.settingProduksi.jumlahProduksiPerHari} unit/hari × ${calculation.settingProduksi.hariKerjaBulan} hari = ${calculation.settingProduksi.totalProduksiBulan} unit/bulan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlighted = false,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: color ?? Colors.blue, width: 2)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
