import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/jenis_produksi.dart';
import '../../domain/entities/skala_usaha.dart';
import '../../domain/entities/periode_komponen.dart';
import '../../domain/entities/komponen_biaya.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../presentation/cubits/hpp_calculator_cubit.dart';
import '../../presentation/cubits/hpp_calculator_state.dart';
import '../widgets/komponen_biaya_input.dart';
import '../widgets/hpp_result_card.dart';
import '../widgets/bep_analysis_card.dart';
import '../widgets/profit_analysis_card.dart';

class NewHppCalculatorPage extends StatefulWidget {
  const NewHppCalculatorPage({super.key});

  @override
  State<NewHppCalculatorPage> createState() => _NewHppCalculatorPageState();
}

class _NewHppCalculatorPageState extends State<NewHppCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final _namaProdukController = TextEditingController();
  final _profitMarginController = TextEditingController(text: '30');
  final _jumlahProduksiController = TextEditingController(text: '1');
  final _hariKerjaController = TextEditingController(text: '25');

  // Setting produksi
  JenisProduksi _jenisProduksi = JenisProduksi.harian;
  SkalaUsaha _skalaUsaha = SkalaUsaha.rumahan;

  // Komponen biaya
  final List<KomponenBiaya> _komponenBiaya = [];

  // BEP inputs
  final _biayaTetapController = TextEditingController();
  bool _showBepSection = false;

  // Profit Analysis inputs
  final _targetPenjualanController = TextEditingController();
  final _investasiAwalController = TextEditingController();
  bool _showProfitSection = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaultKomponen();
  }

  void _initializeDefaultKomponen() {
    _komponenBiaya.addAll([
      KomponenBiaya(
        id: _uuid.v4(),
        nama: 'Bahan Baku',
        nilai: 0,
        periode: PeriodeKomponen.harian,
        keterangan: 'Biaya bahan baku untuk produksi',
      ),
      KomponenBiaya(
        id: _uuid.v4(),
        nama: 'Tenaga Kerja',
        nilai: 0,
        periode: PeriodeKomponen.harian,
        keterangan: 'Upah tenaga kerja',
      ),
      KomponenBiaya(
        id: _uuid.v4(),
        nama: 'Overhead Pabrik',
        nilai: 0,
        periode: PeriodeKomponen.bulanan,
        keterangan: 'Listrik, air, sewa tempat',
      ),
    ]);
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _profitMarginController.dispose();
    _jumlahProduksiController.dispose();
    _hariKerjaController.dispose();
    _biayaTetapController.dispose();
    _targetPenjualanController.dispose();
    _investasiAwalController.dispose();
    super.dispose();
  }

  void _hitungHpp() {
    if (_formKey.currentState!.validate()) {
      final settingProduksi = SettingProduksi(
        jenisProduksi: _jenisProduksi,
        hariKerjaBulan: int.tryParse(_hariKerjaController.text) ?? 25,
        jumlahProduksiPerHari: int.tryParse(_jumlahProduksiController.text) ?? 1,
      );

      context.read<HppCalculatorCubit>().calculateHpp(
            namaProduk: _namaProdukController.text.trim(),
            skalaUsaha: _skalaUsaha,
            settingProduksi: settingProduksi,
            komponenBiaya: _komponenBiaya,
            profitMargin: double.tryParse(_profitMarginController.text) ?? 30,
          );
    }
  }

  void _hitungBep() {
    final state = context.read<HppCalculatorCubit>().state;
    if (state is! HppCalculatorSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hitung HPP terlebih dahulu')),
      );
      return;
    }

    final biayaTetap = double.tryParse(_biayaTetapController.text) ?? 0;
    final calculation = state.calculation;

    context.read<HppCalculatorCubit>().calculateBep(
          biayaTetapBulanan: biayaTetap,
          biayaVariabelPerUnit: calculation.hppPerUnit,
          hargaJualPerUnit: calculation.hargaJualPerUnit,
          produksiPerHari: calculation.settingProduksi.jumlahProduksiPerHari,
          hariKerjaBulan: calculation.settingProduksi.hariKerjaBulan,
        );

    setState(() => _showBepSection = true);
  }

  void _hitungProfit() {
    final state = context.read<HppCalculatorCubit>().state;
    if (state is! HppCalculatorSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hitung HPP terlebih dahulu')),
      );
      return;
    }

    final calculation = state.calculation;
    final targetPenjualan = int.tryParse(_targetPenjualanController.text) ?? 0;
    final biayaTetap = double.tryParse(_biayaTetapController.text) ?? 0;
    final investasiAwal = double.tryParse(_investasiAwalController.text);

    context.read<HppCalculatorCubit>().calculateProfitAnalysis(
          hppPerUnit: calculation.hppPerUnit,
          hargaJualPerUnit: calculation.hargaJualPerUnit,
          jumlahProduksi: calculation.settingProduksi.jumlahProduksiPerHari,
          targetPenjualan: targetPenjualan,
          biayaTetapBulanan: biayaTetap,
          investasiAwal: investasiAwal,
        );

    setState(() => _showProfitSection = true);
  }

  void _addKomponen() {
    setState(() {
      _komponenBiaya.add(KomponenBiaya(
        id: _uuid.v4(),
        nama: 'Komponen Baru',
        nilai: 0,
        periode: PeriodeKomponen.harian,
      ));
    });
  }

  void _removeKomponen(String id) {
    setState(() {
      _komponenBiaya.removeWhere((k) => k.id == id);
    });
  }

  void _updateKomponen(KomponenBiaya updated) {
    setState(() {
      final index = _komponenBiaya.indexWhere((k) => k.id == updated.id);
      if (index != -1) {
        _komponenBiaya[index] = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator HPP Pro'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<HppCalculatorCubit, HppCalculatorState>(
        listener: (context, state) {
          if (state is HppCalculatorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 16),
                  _buildKomponenBiayaSection(),
                  const SizedBox(height: 16),
                  _buildCalculateButton(),
                  if (state is HppCalculatorSuccess) ...[
                    const SizedBox(height: 24),
                    HppResultCard(calculation: state.calculation),
                    const SizedBox(height: 16),
                    _buildBepInputSection(),
                    if (_showBepSection && state.bepAnalysis != null) ...[
                      const SizedBox(height: 16),
                      BepAnalysisCard(analysis: state.bepAnalysis!),
                    ],
                    const SizedBox(height: 16),
                    _buildProfitInputSection(),
                    if (_showProfitSection && state.profitAnalysis != null) ...[
                      const SizedBox(height: 16),
                      ProfitAnalysisCard(analysis: state.profitAnalysis!),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Fitur Baru!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '✓ Pembeda komponen harian vs bulanan\n'
              '✓ Analisis Break Even Point (BEP)\n'
              '✓ Analisis Profit & ROI',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Dasar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaProdukController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Nama produk wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<JenisProduksi>(
              value: _jenisProduksi,
              decoration: InputDecoration(
                labelText: 'Jenis Produksi',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
                helperText: _jenisProduksi.deskripsi,
                helperMaxLines: 2,
              ),
              items: JenisProduksi.values.map((jenis) {
                return DropdownMenuItem(
                  value: jenis,
                  child: Text(jenis.label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _jenisProduksi = value!;
                  _hariKerjaController.text =
                      value.defaultHariKerjaBulan.toString();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SkalaUsaha>(
              value: _skalaUsaha,
              decoration: const InputDecoration(
                labelText: 'Skala Usaha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: SkalaUsaha.values.map((skala) {
                return DropdownMenuItem(
                  value: skala,
                  child: Text(skala.label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _skalaUsaha = value!;
                  _profitMarginController.text =
                      value.rekomendasiProfitMargin.toString();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jumlahProduksiController,
                    decoration: const InputDecoration(
                      labelText: 'Produksi/Hari',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.production_quantity_limits),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final val = int.tryParse(value ?? '');
                      return val == null || val <= 0
                          ? 'Harus > 0'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _hariKerjaController,
                    decoration: const InputDecoration(
                      labelText: 'Hari Kerja/Bulan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _profitMarginController,
              decoration: InputDecoration(
                labelText: 'Profit Margin (%)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.trending_up),
                helperText: 'Rekomendasi: ${_skalaUsaha.rekomendasiProfitMargin}%',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKomponenBiayaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Komponen Biaya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: _addKomponen,
                  tooltip: 'Tambah Komponen',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._komponenBiaya.map((komponen) {
              return KomponenBiayaInput(
                komponen: komponen,
                onUpdate: _updateKomponen,
                onDelete: () => _removeKomponen(komponen.id),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton.icon(
      onPressed: _hitungHpp,
      icon: const Icon(Icons.calculate),
      label: const Text('HITUNG HPP'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBepInputSection() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analisis Break Even Point (BEP)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _biayaTetapController,
              decoration: const InputDecoration(
                labelText: 'Biaya Tetap Bulanan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
                helperText: 'Sewa, gaji tetap, dll yang tidak berubah',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _hitungBep,
              icon: const Icon(Icons.analytics),
              label: const Text('HITUNG BEP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitInputSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analisis Profit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetPenjualanController,
              decoration: const InputDecoration(
                labelText: 'Target Penjualan (unit/bulan)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bar_chart),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _investasiAwalController,
              decoration: const InputDecoration(
                labelText: 'Investasi Awal (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
                prefixText: 'Rp ',
                helperText: 'Untuk menghitung ROI dan payback period',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _hitungProfit,
              icon: const Icon(Icons.trending_up),
              label: const Text('HITUNG PROFIT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
