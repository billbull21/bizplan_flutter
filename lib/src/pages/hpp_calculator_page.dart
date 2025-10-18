import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/hpp_calculator.dart';
import '../models/hpp_template.dart';
import '../services/storage_service.dart';
import '../utils/app_utils.dart';
import 'hpp_template_page.dart';
import '../utils/thousands_separator_input_formatter_utils.dart';

class HppCalculatorPage extends StatefulWidget {
  final HppTemplate? template;

  const HppCalculatorPage({super.key, this.template});

  @override
  State<HppCalculatorPage> createState() => _HppCalculatorPageState();
}

class _HppCalculatorPageState extends State<HppCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  var _calculator = HppCalculator();
  final _bahanBakuController = TextEditingController();
  final _tenagaKerjaController = TextEditingController();
  final _overheadPabrikController = TextEditingController();
  final _biayaLainController = TextEditingController();
  final _jumlahProduksiController = TextEditingController(text: '1');
  final _profitMarginController = TextEditingController(text: '30');
  final _namaProdukController = TextEditingController();
  final _storageService = StorageService();
  final _uuid = const Uuid();
  bool _isCalculated = false;
  SkalaUsaha _selectedSkalaUsaha = SkalaUsaha.rumahan;

  @override
  void initState() {
    super.initState();
    // Jika ada template, isi form dengan data template
    if (widget.template != null) {
      _fillFromTemplate(widget.template!);
    }
  }

  void _fillFromTemplate(HppTemplate template) {
    setState(() {
      // Format angka dengan pemisah ribuan
      _bahanBakuController.text =
          AppUtils.currencyFormat.format(template.calculator.bahanBaku);
      _tenagaKerjaController.text =
          AppUtils.currencyFormat.format(template.calculator.tenagaKerja);
      _overheadPabrikController.text =
          AppUtils.currencyFormat.format(template.calculator.overheadPabrik);
      _biayaLainController.text =
          AppUtils.currencyFormat.format(template.calculator.biayaLain);
      _jumlahProduksiController.text =
          AppUtils.currencyFormat.format(template.calculator.jumlahProduksi);
      _profitMarginController.text =
          AppUtils.currencyFormat.format(template.calculator.profitMargin);
      _selectedSkalaUsaha = template.calculator.skalaUsaha;
      _namaProdukController.text = template.namaProduk;

      // Isi calculator dengan nilai asli (tanpa format)
      _calculator = template.calculator.copy();
      _isCalculated = true;
    });
  }

  @override
  void dispose() {
    _bahanBakuController.dispose();
    _tenagaKerjaController.dispose();
    _overheadPabrikController.dispose();
    _biayaLainController.dispose();
    _jumlahProduksiController.dispose();
    _profitMarginController.dispose();
    _namaProdukController.dispose();
    super.dispose();
  }

  void _hitungHpp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Bersihkan format currency sebelum parsing (hapus semua karakter non-digit)
        _calculator.bahanBaku = double.tryParse(
                _bahanBakuController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
            0;
        _calculator.tenagaKerja = double.tryParse(
                _tenagaKerjaController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
            0;
        _calculator.overheadPabrik = double.tryParse(_overheadPabrikController
                .text
                .replaceAll(RegExp(r'[^\d]'), '')) ??
            0;
        _calculator.biayaLain = double.tryParse(
                _biayaLainController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
            0;
        _calculator.jumlahProduksi =
            int.tryParse(_jumlahProduksiController.text) ?? 1;
        _calculator.skalaUsaha = _selectedSkalaUsaha;
        _calculator.profitMargin =
            double.tryParse(_profitMarginController.text) ?? 30;
        _isCalculated = true;
      });
    }
  }

  void _updateProfitMarginBasedOnScale() {
    setState(() {
      _profitMarginController.text =
          _calculator.rekomendasiProfitMargin.toString();
    });
  }

  // Future<void> _simpanPerhitungan() async {
  //   if (!_isCalculated) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Harap hitung HPP terlebih dahulu')),
  //     );
  //     return;
  //   }

  //   // Tampilkan dialog untuk input nama produk
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Simpan Perhitungan'),
  //       content: TextField(
  //         controller: _namaProdukController,
  //         decoration: const InputDecoration(
  //           labelText: 'Nama Produk',
  //           hintText: 'Masukkan nama produk',
  //         ),
  //         autofocus: true,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('BATAL'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             if (_namaProdukController.text.trim().isEmpty) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                     content: Text('Nama produk tidak boleh kosong')),
  //               );
  //               return;
  //             }

  //             // Buat objek history
  //             final history = HppHistory(
  //               id: _uuid.v4(),
  //               namaProduk: _namaProdukController.text.trim(),
  //               calculator: HppCalculator(
  //                 bahanBaku: _calculator.bahanBaku,
  //                 tenagaKerja: _calculator.tenagaKerja,
  //                 overheadPabrik: _calculator.overheadPabrik,
  //                 biayaLain: _calculator.biayaLain,
  //                 jumlahProduksi: _calculator.jumlahProduksi,
  //                 skalaUsaha: _calculator.skalaUsaha,
  //                 profitMargin: _calculator.profitMargin,
  //               ),
  //               timestamp: DateTime.now(),
  //             );

  //             // Simpan ke storage
  //             await _storageService.addHistory(history);

  //             if (mounted) {
  //               Navigator.pop(context);
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                     content: Text('Perhitungan berhasil disimpan')),
  //               );
  //               _namaProdukController.clear();
  //             }
  //           },
  //           child: const Text('SIMPAN'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _lihatRiwayat() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HppHistoryPage()),
  //   );
  // }

  void _lihatTemplate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HppTemplatePage()),
    );
  }

  Future<void> _simpanTemplate() async {
    if (!_isCalculated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap hitung HPP terlebih dahulu')),
      );
      return;
    }

    // Tampilkan dialog untuk input nama template
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simpan Template'),
        content: TextField(
          controller: _namaProdukController,
          decoration: const InputDecoration(
            labelText: 'Nama Template',
            hintText: 'Masukkan nama template',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () async {
              if (_namaProdukController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Nama template tidak boleh kosong')),
                );
                return;
              }

              // Buat objek template
              final template = HppTemplate(
                id: _uuid.v4(),
                namaProduk: _namaProdukController.text.trim(),
                calculator: HppCalculator(
                  bahanBaku: _calculator.bahanBaku,
                  tenagaKerja: _calculator.tenagaKerja,
                  overheadPabrik: _calculator.overheadPabrik,
                  biayaLain: _calculator.biayaLain,
                  jumlahProduksi: _calculator.jumlahProduksi,
                  skalaUsaha: _calculator.skalaUsaha,
                  profitMargin: _calculator.profitMargin,
                ),
                timestamp: DateTime.now(),
              );

              // Simpan ke storage
              await _storageService.addTemplate(template);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template berhasil disimpan')),
                );
              }
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(Map<String, String> info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(info['title'] ?? 'Informasi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info['description'] ?? ''),
              const SizedBox(height: 8),
              Text(info['contoh'] ?? '',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text(info['tips'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (info.containsKey('rumahan')) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(info['rumahan'] ?? '',
                    style: const TextStyle(color: Colors.blue)),
                const SizedBox(height: 8),
                Text(info['sedang'] ?? '',
                    style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 8),
                Text(info['tinggi'] ?? '',
                    style: const TextStyle(color: Colors.orange)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator HPP | Obizplan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _lihatTemplate,
            tooltip: 'Template',
          ),
          // IconButton(
          //   icon: const Icon(Icons.history),
          //   onPressed: _lihatRiwayat,
          //   tooltip: 'Lihat Riwayat',
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Input Biaya Produksi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Skala Usaha Dropdown
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Skala Usaha',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: Colors.blue),
                            onPressed: () => _showInfoDialog(
                                HppCalculator.informasiSkalaUsaha),
                            tooltip: 'Informasi Skala Usaha',
                          ),
                        ],
                      ),
                      DropdownButtonFormField<SkalaUsaha>(
                        value: _selectedSkalaUsaha,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: SkalaUsaha.values.map((skala) {
                          String label;
                          switch (skala) {
                            case SkalaUsaha.rumahan:
                              label = 'Usaha Rumahan';
                              break;
                            case SkalaUsaha.sedang:
                              label = 'Usaha Sedang';
                              break;
                            case SkalaUsaha.tinggi:
                              label = 'Usaha Tinggi';
                              break;
                          }
                          return DropdownMenuItem<SkalaUsaha>(
                            value: skala,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSkalaUsaha = value!;
                            _calculator.skalaUsaha = value;
                            _updateProfitMarginBasedOnScale();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInputFieldWithInfo(
                        label: 'Biaya Bahan Baku',
                        hint: 'Masukkan biaya bahan baku',
                        controller: _bahanBakuController,
                        icon: Icons.inventory,
                        infoMap: HppCalculator.informasiBahanBaku,
                      ),
                      _buildInputFieldWithInfo(
                        label: 'Biaya Tenaga Kerja',
                        hint: 'Masukkan biaya tenaga kerja',
                        controller: _tenagaKerjaController,
                        icon: Icons.people,
                        infoMap: HppCalculator.informasiTenagaKerja,
                      ),
                      _buildInputFieldWithInfo(
                        label: 'Biaya Overhead Pabrik',
                        hint: 'Masukkan biaya overhead pabrik',
                        controller: _overheadPabrikController,
                        icon: Icons.factory,
                        infoMap: HppCalculator.informasiOverheadPabrik,
                      ),
                      _buildInputFieldWithInfo(
                        label: 'Biaya Lain-lain',
                        hint: 'Masukkan biaya lain-lain',
                        controller: _biayaLainController,
                        icon: Icons.miscellaneous_services,
                        infoMap: HppCalculator.informasiBiayaLain,
                      ),
                      _buildInputFieldWithInfo(
                        label: 'Jumlah Produksi (unit)',
                        hint: 'Masukkan jumlah produksi',
                        controller: _jumlahProduksiController,
                        icon: Icons.production_quantity_limits,
                        defaultTextLabel: '',
                        infoMap: HppCalculator.informasiJumlahProduksi,
                      ),
                      _buildInputFieldWithInfo(
                        label: 'Profit Margin (%)',
                        hint: 'Masukkan profit margin',
                        controller: _profitMarginController,
                        icon: Icons.trending_up,
                        isInteger: true,
                        infoMap: HppCalculator.informasiProfitMargin,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _hitungHpp,
                          icon: const Icon(Icons.calculate),
                          label: const Text('HITUNG HPP'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hasil Perhitungan HPP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultItem(
                        label: 'Total Biaya Produksi',
                        value: AppUtils.formatCurrency(_calculator.totalBiaya),
                      ),
                      const Divider(),
                      _buildResultItem(
                        label: 'HPP per Unit',
                        value: AppUtils.formatCurrency(_calculator.hppPerUnit),
                        isHighlighted: true,
                      ),
                      if (_isCalculated) ...[
                        const Divider(height: 24),
                        const Text(
                          'Profit Margin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildResultItem(
                          label: 'Profit Margin',
                          value:
                              '${AppUtils.formatNumber(_calculator.profitMargin)}%',
                        ),
                        _buildResultItem(
                          label: 'Profit per Unit',
                          value: AppUtils.formatCurrency(
                              _calculator.profitPerUnit),
                        ),
                        _buildResultItem(
                          label: 'Harga Jual per Unit',
                          value: AppUtils.formatCurrency(
                              _calculator.hargaJualPerUnit),
                          isHighlighted: true,
                        ),
                        _buildResultItem(
                          label: 'Total Profit',
                          value:
                              AppUtils.formatCurrency(_calculator.totalProfit),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _simpanTemplate,
                              icon: const Icon(Icons.bookmark_add),
                              label: const Text('SIMPAN TEMPLATE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                          // Wrap(
                          //   alignment: WrapAlignment.center,
                          //   runAlignment: WrapAlignment.center,
                          //   crossAxisAlignment: WrapCrossAlignment.center,
                          //   spacing: 8,
                          //   runSpacing: 8,
                          //   children: [
                          //     ElevatedButton.icon(
                          //       onPressed: _simpanPerhitungan,
                          //       icon: const Icon(Icons.save),
                          //       label: const Text('SIMPAN PERHITUNGAN'),
                          //       style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors.green,
                          //         foregroundColor: Colors.white,
                          //         padding: const EdgeInsets.symmetric(
                          //           vertical: 12,
                          //           horizontal: 8,
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 8),
                          //     ,
                          //   ],
                          // ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keterangan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Biaya Bahan Baku: Semua biaya untuk bahan utama pembuatan produk',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '• Biaya Tenaga Kerja: Upah pekerja yang terlibat dalam produksi',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '• Biaya Overhead Pabrik: Biaya listrik, air, sewa tempat, dll',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '• Biaya Lain-lain: Biaya tambahan yang tidak termasuk kategori di atas',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Dibuat dengan ❤️ oleh oemam.netlify.app",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    OutlinedButton.icon(
                      icon: Icon(Icons.open_in_new),
                      label: Text("Kunjungi oemam.netlify.app"),
                      onPressed: () =>
                          launchUrl(Uri.parse('https://oemam.netlify.app/')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldWithInfo({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isInteger = false,
    String defaultTextLabel = "Rp.",
    required Map<String, String> infoMap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue),
                onPressed: () => _showInfoDialog(infoMap),
                tooltip: 'Informasi $label',
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(icon),
              prefixText: !isInteger && label != 'Profit Margin (%)'
                  ? defaultTextLabel
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              // Gunakan formatter yang berbeda berdasarkan jenis input
              if (isInteger || label == 'Profit Margin (%)')
                FilteringTextInputFormatter.digitsOnly
              else
                ThousandsSeparatorInputFormatterUtils(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap masukkan nilai';
              }

              // Hapus format currency untuk validasi
              final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

              if (isInteger) {
                final intValue = int.tryParse(cleanValue);
                if (intValue == null || intValue <= 0) {
                  return 'Harap masukkan angka positif';
                }
              } else {
                final doubleValue = double.tryParse(cleanValue);
                if (doubleValue == null || doubleValue < 0) {
                  return 'Harap masukkan angka valid';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.blue.shade800 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
