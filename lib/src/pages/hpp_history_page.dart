import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hpp_history.dart';
import '../services/storage_service.dart';

class HppHistoryPage extends StatefulWidget {
  const HppHistoryPage({super.key});

  @override
  State<HppHistoryPage> createState() => _HppHistoryPageState();
}

class _HppHistoryPageState extends State<HppHistoryPage> {
  final _storageService = StorageService();
  List<HppHistory> _histories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() => _isLoading = true);
    final histories = await _storageService.getHistories();
    setState(() {
      _histories = histories;
      _isLoading = false;
    });
  }

  Future<void> _deleteHistory(String id) async {
    await _storageService.deleteHistory(id);
    _loadHistories();
  }

  String _formatCurrency(double value) {
    // Menghilangkan 0 di belakang koma jika tidak diperlukan
    final NumberFormat formatter = NumberFormat('#,###', 'id_ID');
    if (value == value.toInt()) {
      // Jika nilai adalah bilangan bulat (tidak ada desimal)
      return 'Rp ${formatter.format(value.toInt())}';
    } else {
      // Jika nilai memiliki desimal
      return 'Rp ${formatter.format(value)}';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Perhitungan HPP'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_histories.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Semua Riwayat'),
                    content: const Text('Apakah Anda yakin ingin menghapus semua riwayat perhitungan?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('BATAL'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _storageService.clearAllHistories();
                          if (mounted) {
                            Navigator.pop(context);
                            _loadHistories();
                          }
                        },
                        child: const Text('HAPUS'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat perhitungan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Riwayat akan muncul setelah Anda menyimpan perhitungan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _histories.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final history = _histories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    history.namaProduk,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteHistory(history.id),
                                  color: Colors.red,
                                  tooltip: 'Hapus',
                                ),
                              ],
                            ),
                            Text(
                              _formatDate(history.timestamp),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const Divider(),
                            _buildHistoryItem('Biaya Bahan Baku', history.calculator.bahanBaku),
                            _buildHistoryItem('Biaya Tenaga Kerja', history.calculator.tenagaKerja),
                            _buildHistoryItem('Biaya Overhead', history.calculator.overheadPabrik),
                            _buildHistoryItem('Biaya Lain-lain', history.calculator.biayaLain),
                            const Divider(),
                            _buildHistoryItem('Total Biaya', history.calculator.totalBiaya, isBold: true),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Jumlah Produksi:'),
                                Text('${history.calculator.jumlahProduksi} unit'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'HPP per Unit:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(history.calculator.hppPerUnit),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildHistoryItem(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}