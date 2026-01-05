import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/jenis_produksi.dart';
import '../../domain/entities/skala_usaha.dart';
import '../../domain/entities/periode_komponen.dart';
import '../../domain/entities/komponen_biaya.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../presentation/cubits/hpp_calculator_cubit.dart';
import '../../presentation/cubits/hpp_calculator_state.dart';
import '../../utils/thousands_separator_input_formatter_utils.dart';
import '../widgets/komponen_biaya_input.dart';
import '../widgets/hpp_result_card.dart';
import '../widgets/bep_analysis_card.dart';
import '../widgets/profit_analysis_card.dart';

class StepperHppCalculatorPage extends StatefulWidget {
  const StepperHppCalculatorPage({super.key});

  @override
  State<StepperHppCalculatorPage> createState() => _StepperHppCalculatorPageState();
}

class _StepperHppCalculatorPageState extends State<StepperHppCalculatorPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  
  // Controllers
  final _namaProdukController = TextEditingController();
  final _profitMarginController = TextEditingController(text: '30');
  final _jumlahProduksiController = TextEditingController(text: '1');
  final _hariKerjaController = TextEditingController(text: '25');
  final _biayaTetapController = TextEditingController();
  final _targetPenjualanController = TextEditingController();
  final _investasiAwalController = TextEditingController();

  // Settings
  JenisProduksi _jenisProduksi = JenisProduksi.harian;
  SkalaUsaha _skalaUsaha = SkalaUsaha.rumahan;
  final List<KomponenBiaya> _komponenBiaya = [];

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
    _pageController.dispose();
    _namaProdukController.dispose();
    _profitMarginController.dispose();
    _jumlahProduksiController.dispose();
    _hariKerjaController.dispose();
    _biayaTetapController.dispose();
    _targetPenjualanController.dispose();
    _investasiAwalController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _hitungHpp() {
    if (!_formKey.currentState!.validate()) return;

    final settingProduksi = SettingProduksi(
      jenisProduksi: _jenisProduksi,
      hariKerjaBulan: int.tryParse(_hariKerjaController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 25,
      jumlahProduksiPerHari: int.tryParse(_jumlahProduksiController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 1,
    );

    context.read<HppCalculatorCubit>().calculateHpp(
          namaProduk: _namaProdukController.text.trim(),
          skalaUsaha: _skalaUsaha,
          settingProduksi: settingProduksi,
          komponenBiaya: _komponenBiaya,
          profitMargin: double.tryParse(_profitMarginController.text) ?? 30,
        );

    _nextStep(); // Go to results
  }

  void _hitungBep() {
    final state = context.read<HppCalculatorCubit>().state;
    if (state is! HppCalculatorSuccess) return;

    final biayaTetap = double.tryParse(
          _biayaTetapController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;
    final calculation = state.calculation;

    context.read<HppCalculatorCubit>().calculateBep(
          biayaTetapBulanan: biayaTetap,
          biayaVariabelPerUnit: calculation.hppPerUnit,
          hargaJualPerUnit: calculation.hargaJualPerUnit,
          produksiPerHari: calculation.settingProduksi.jumlahProduksiPerHari,
          hariKerjaBulan: calculation.settingProduksi.hariKerjaBulan,
        );
  }

  void _hitungProfit() {
    final state = context.read<HppCalculatorCubit>().state;
    if (state is! HppCalculatorSuccess) return;

    final calculation = state.calculation;
    final targetPenjualan = int.tryParse(_targetPenjualanController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    final biayaTetap = double.tryParse(
          _biayaTetapController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;
    final investasiAwal = double.tryParse(
        _investasiAwalController.text.replaceAll(RegExp(r'[^\d]'), ''));

    context.read<HppCalculatorCubit>().calculateProfitAnalysis(
          hppPerUnit: calculation.hppPerUnit,
          hargaJualPerUnit: calculation.hargaJualPerUnit,
          jumlahProduksi: calculation.settingProduksi.jumlahProduksiPerHari,
          targetPenjualan: targetPenjualan,
          biayaTetapBulanan: biayaTetap,
          investasiAwal: investasiAwal,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator HPP Pro'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: BlocConsumer<HppCalculatorCubit, HppCalculatorState>(
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
                return Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => setState(() => _currentStep = index),
                    children: [
                      _buildStep1BasicInfo(),
                      _buildStep2KomponenBiaya(),
                      _buildStep3HppResult(state),
                      _buildStep4Analysis(state),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Info Dasar', Icons.info),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Komponen', Icons.list),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'HPP', Icons.calculate),
          _buildStepConnector(2),
          _buildStepIndicator(3, 'Analisis', Icons.analytics),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green
                  : isActive
                      ? Colors.blue
                      : Colors.grey.shade300,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isCompleted ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Informasi Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaProdukController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                      helperText: 'Contoh: Kue Brownies, Kaos Custom, dll',
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
                          inputFormatters: [ThousandsSeparatorInputFormatterUtils()],
                          validator: (value) {
                            final cleanValue = value?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
                            final val = int.tryParse(cleanValue);
                            return val == null || val <= 0 ? 'Harus > 0' : null;
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
                          inputFormatters: [ThousandsSeparatorInputFormatterUtils()],
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
                      helperText:
                          'Rekomendasi: ${_skalaUsaha.rekomendasiProfitMargin}%',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatterUtils()],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoBox(
            '💡 Tentang HPP Per Produk',
            'Perhitungan HPP harus dilakukan PER PRODUK. Jika Anda memproduksi beberapa jenis produk dalam satu siklus:\n\n'
                '1. Hitung HPP untuk SETIAP produk secara terpisah\n'
                '2. Alokasikan biaya bersama (overhead) secara proporsional\n'
                '3. Gunakan metode ABC Costing untuk overhead yang kompleks\n\n'
                'Contoh: Jika produksi Brownies & Cookies bersamaan, buat 2 kalkulasi terpisah dengan alokasi overhead yang sesuai.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep2KomponenBiaya() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '💰 Komponen Biaya',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _komponenBiaya.add(KomponenBiaya(
                              id: _uuid.v4(),
                              nama: 'Komponen Baru',
                              nilai: 0,
                              periode: PeriodeKomponen.harian,
                            ));
                          });
                        },
                        tooltip: 'Tambah Komponen',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._komponenBiaya.map((komponen) {
                    return KomponenBiayaInput(
                      komponen: komponen,
                      onUpdate: (updated) {
                        setState(() {
                          final index =
                              _komponenBiaya.indexWhere((k) => k.id == updated.id);
                          if (index != -1) {
                            _komponenBiaya[index] = updated;
                          }
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _komponenBiaya.removeWhere((k) => k.id == komponen.id);
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoBox(
            '📌 Tips Komponen Biaya',
            'HARIAN: Bahan baku yang cepat habis, upah harian\n'
                'MINGGUAN: Pembelian berkala mingguan\n'
                'BULANAN: Sewa, gaji tetap, listrik, air\n\n'
                'Pastikan semua biaya tercatat untuk HPP yang akurat!',
          ),
        ],
      ),
    );
  }

  Widget _buildStep3HppResult(HppCalculatorState state) {
    if (state is! HppCalculatorSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Belum ada hasil perhitungan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _currentStep = 1);
                _pageController.jumpToPage(1);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Input'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HppResultCard(calculation: state.calculation),
          const SizedBox(height: 16),
          _buildInfoBox(
            '✅ HPP Berhasil Dihitung!',
            'Lanjutkan ke langkah berikutnya untuk analisis BEP dan Profit yang lebih mendalam.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Analysis(HppCalculatorState state) {
    if (state is! HppCalculatorSuccess) {
      return const Center(child: Text('Hitung HPP terlebih dahulu'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Analisis BEP',
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
                    inputFormatters: [ThousandsSeparatorInputFormatterUtils()],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _hitungBep,
                    icon: const Icon(Icons.analytics),
                    label: const Text('HITUNG BEP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.bepAnalysis != null) ...[
            const SizedBox(height: 16),
            BepAnalysisCard(analysis: state.bepAnalysis!),
          ],
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💹 Analisis Profit',
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
                    inputFormatters: [ThousandsSeparatorInputFormatterUtils()],
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
                    inputFormatters: [ThousandsSeparatorInputFormatterUtils()],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _hitungProfit,
                    icon: const Icon(Icons.trending_up),
                    label: const Text('HITUNG PROFIT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.profitAnalysis != null) ...[
            const SizedBox(height: 16),
            ProfitAnalysisCard(analysis: state.profitAnalysis!),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentStep == 1) {
                  _hitungHpp();
                } else if (_currentStep < 3) {
                  _nextStep();
                }
              },
              icon: Icon(_currentStep == 1 ? Icons.calculate : Icons.arrow_forward),
              label: Text(_currentStep == 1 ? 'HITUNG HPP' : 'Lanjut'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
          ),
        ],
      ),
    );
  }
}
