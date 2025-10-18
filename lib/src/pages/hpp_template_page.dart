import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hpp_template.dart';
import '../services/storage_service.dart';
import 'hpp_calculator_page.dart';

class HppTemplatePage extends StatefulWidget {
  const HppTemplatePage({super.key});

  @override
  State<HppTemplatePage> createState() => _HppTemplatePageState();
}

class _HppTemplatePageState extends State<HppTemplatePage> {
  final _storageService = StorageService();
  List<HppTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });
    
    final templates = await _storageService.getTemplateList();
    
    setState(() {
      _templates = templates;
      _isLoading = false;
    });
  }

  Future<void> _deleteTemplate(String id) async {
    await _storageService.deleteTemplate(id);
    _loadTemplates();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template HPP'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada template tersimpan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Simpan perhitungan sebagai template untuk digunakan kembali',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('KEMBALI KE KALKULATOR'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
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
                                    template.namaProduk,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteTemplate(template.id),
                                      tooltip: 'Hapus Template',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HppCalculatorPage(
                                              template: template,
                                            ),
                                          ),
                                        ).then((_) => _loadTemplates());
                                      },
                                      tooltip: 'Gunakan Template',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            _buildTemplateDetail(
                              'Bahan Baku',
                              _formatCurrency(template.calculator.bahanBaku),
                            ),
                            _buildTemplateDetail(
                              'Tenaga Kerja',
                              _formatCurrency(template.calculator.tenagaKerja),
                            ),
                            _buildTemplateDetail(
                              'Overhead Pabrik',
                              _formatCurrency(template.calculator.overheadPabrik),
                            ),
                            _buildTemplateDetail(
                              'Biaya Lain',
                              _formatCurrency(template.calculator.biayaLain),
                            ),
                            _buildTemplateDetail(
                              'Jumlah Produksi',
                              '${template.calculator.jumlahProduksi} unit',
                            ),
                            _buildTemplateDetail(
                              'Profit Margin',
                              '${template.calculator.profitMargin}%',
                            ),
                            const Divider(),
                            _buildTemplateDetail(
                              'HPP per Unit',
                              _formatCurrency(template.calculator.hppPerUnit),
                              isHighlighted: true,
                            ),
                            _buildTemplateDetail(
                              'Harga Jual per Unit',
                              _formatCurrency(template.calculator.hargaJualPerUnit),
                              isHighlighted: true,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HppCalculatorPage(
                                        template: template,
                                      ),
                                    ),
                                  ).then((_) => _loadTemplates());
                                },
                                icon: const Icon(Icons.file_copy),
                                label: const Text('GUNAKAN TEMPLATE INI'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
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

  Widget _buildTemplateDetail(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.blue.shade800 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}