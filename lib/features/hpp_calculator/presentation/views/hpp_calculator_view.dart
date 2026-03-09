import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/thousands_separator_formatter.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/jenis_produksi.dart';
import '../../domain/entities/komponen_biaya.dart';
import '../../domain/entities/periode_komponen.dart';
import '../../domain/entities/skala_usaha.dart';
import '../viewmodels/hpp_calculator_state.dart';
import '../viewmodels/hpp_calculator_viewmodel.dart';
import '../widgets/komponen_biaya_input.dart';
import '../widgets/hpp_result_card.dart';
import '../widgets/bep_analysis_card.dart';
import '../widgets/profit_analysis_card.dart';
import '../widgets/step_indicator.dart';
import '../widgets/ai_insight_card.dart';
import '../viewmodels/ai_insight_viewmodel.dart';
import '../../../../app/router/app_router.dart';

class HppCalculatorView extends StatefulWidget {
  const HppCalculatorView({super.key});

  @override
  State<HppCalculatorView> createState() => _HppCalculatorViewState();
}

class _HppCalculatorViewState extends State<HppCalculatorView> {
  final _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Controllers
  final _namaProdukController = TextEditingController();
  final _profitMarginController = TextEditingController(text: '30');
  final _jumlahProduksiController = TextEditingController(text: '1');
  final _hariKerjaController = TextEditingController(text: '25');
  final _jumlahProduksiBatchController = TextEditingController(text: '50');
  final _frekuensiBatchController = TextEditingController(text: '4');
  final _biayaTetapController = TextEditingController();
  final _targetPenjualanController = TextEditingController();
  final _investasiAwalController = TextEditingController();

  // State
  JenisProduksi _jenisProduksi = JenisProduksi.harian;
  SkalaUsaha _skalaUsaha = SkalaUsaha.rumahan;
  final List<KomponenBiaya> _komponenBiaya = [];
  bool _showAiInsight = false;

  @override
  void initState() {
    super.initState();
    _initDefaultKomponen();
  }

  void _initDefaultKomponen() {
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
        nama: 'Overhead',
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
    _jumlahProduksiBatchController.dispose();
    _frekuensiBatchController.dispose();
    _biayaTetapController.dispose();
    _targetPenjualanController.dispose();
    _investasiAwalController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextStep() {
    if (_currentStep < 3) _goToStep(_currentStep + 1);
  }

  void _previousStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  void _hitungHpp() {
    if (!_formKey.currentState!.validate()) return;

    final isBatch = _jenisProduksi == JenisProduksi.batch;
    final hariKerja = isBatch
        ? 25
        : int.tryParse(
                _hariKerjaController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
            25;

    final settingProduksi = SettingProduksi(
      jenisProduksi: _jenisProduksi,
      hariKerjaBulan: hariKerja,
      jumlahProduksiPerHari: isBatch
          ? 0
          : int.tryParse(
                  _jumlahProduksiController.text
                      .replaceAll(RegExp(r'[^\d]'), '')) ??
              1,
      jumlahProduksiBatch: isBatch
          ? int.tryParse(
                  _jumlahProduksiBatchController.text
                      .replaceAll(RegExp(r'[^\d]'), '')) ??
              50
          : null,
      frekuensiBatchPerBulan: isBatch
          ? int.tryParse(
                  _frekuensiBatchController.text
                      .replaceAll(RegExp(r'[^\d]'), '')) ??
              4
          : null,
    );

    // Auto-populate biaya tetap dari komponen yang ditandai tetap
    final biayaTetapTotal = _komponenBiaya
        .where((k) => k.isTetap)
        .fold(0.0, (sum, k) {
      double nilaiBulanan;
      switch (k.periode) {
        case PeriodeKomponen.harian:
          nilaiBulanan = k.nilai * hariKerja;
          break;
        case PeriodeKomponen.perBatch:
          nilaiBulanan = k.nilai *
              (settingProduksi.frekuensiBatchPerBulan ?? 1);
          break;
        case PeriodeKomponen.mingguan:
          nilaiBulanan = k.nilai * (52.0 / 12.0);
          break;
        case PeriodeKomponen.bulanan:
          nilaiBulanan = k.nilai;
          break;
      }
      return sum + nilaiBulanan;
    });

    if (biayaTetapTotal > 0 && _biayaTetapController.text.isEmpty) {
      final formatter = NumberFormat('#,###', 'id_ID');
      _biayaTetapController.text =
          formatter.format(biayaTetapTotal.toInt());
    }

    context.read<HppCalculatorViewModel>().calculateHpp(
          namaProduk: _namaProdukController.text.trim(),
          skalaUsaha: _skalaUsaha,
          settingProduksi: settingProduksi,
          komponenBiaya: _komponenBiaya,
          profitMargin: double.tryParse(_profitMarginController.text) ?? 30,
        );

    // Reset AI insight agar user bisa trigger analisis baru
    context.read<AiInsightViewModel>().reset();
    setState(() => _showAiInsight = false);

    _nextStep();
  }

  void _hitungBep() {
    final vmState = context.read<HppCalculatorViewModel>().state;
    if (vmState is! HppCalculatorSuccess) return;

    final biayaTetap = double.tryParse(
            _biayaTetapController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;

    context.read<HppCalculatorViewModel>().calculateBep(
          biayaTetapBulanan: biayaTetap,
          biayaVariabelPerUnit:
              vmState.calculation.hitungBiayaVariabelPerUnit(biayaTetap),
          hargaJualPerUnit: vmState.calculation.hargaJualPerUnit,
          produksiBulanan:
              vmState.calculation.settingProduksi.totalProduksiBulan,
        );
  }

  void _hitungProfit() {
    final vmState = context.read<HppCalculatorViewModel>().state;
    if (vmState is! HppCalculatorSuccess) return;

    final targetPenjualan = int.tryParse(
            _targetPenjualanController.text
                .replaceAll(RegExp(r'[^\d]'), '')) ??
        0;
    final biayaTetap = double.tryParse(
            _biayaTetapController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;
    final investasiAwal = double.tryParse(
        _investasiAwalController.text.replaceAll(RegExp(r'[^\d]'), ''));

    context.read<HppCalculatorViewModel>().calculateProfitAnalysis(
          biayaVariabelPerUnit:
              vmState.calculation.hitungBiayaVariabelPerUnit(biayaTetap),
          hargaJualPerUnit: vmState.calculation.hargaJualPerUnit,
          jumlahProduksi:
              vmState.calculation.settingProduksi.totalProduksiBulan,
          targetPenjualan: targetPenjualan,
          biayaTetapBulanan: biayaTetap,
          investasiAwal: investasiAwal,
        );
  }

  void _navigateToShare() {
    final vmState = context.read<HppCalculatorViewModel>().state;
    if (vmState is HppCalculatorSuccess) {
      context.push(
        AppRouter.share,
        extra: {
          'calculation': vmState.calculation,
          'bepAnalysis': vmState.bepAnalysis,
          'profitAnalysis': vmState.profitAnalysis,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          StepIndicator(currentStep: _currentStep),
          Expanded(
            child: BlocConsumer<HppCalculatorViewModel, HppCalculatorState>(
              listener: (context, state) {
                if (state is HppCalculatorError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(state.message)),
                          ],
                        ),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(state),
                      _buildStep4(state),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: _currentStep > 0
          ? null
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/logo.png',
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Obizplan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
          const Text(
            'Kalkulator HPP Pro',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: () {
            context.read<HppCalculatorViewModel>().reset();
            _goToStep(0);
            _biayaTetapController.clear();
            _targetPenjualanController.clear();
            _investasiAwalController.clear();
          },
          tooltip: 'Reset',
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // STEP 1 – Info Dasar
  // ─────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Informasi Produk', Icons.inventory_2_outlined),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: [
                _buildFormField(
                  controller: _namaProdukController,
                  label: 'Nama Produk',
                  hint: 'cth: Kue Brownies, Kaos Custom',
                  icon: Icons.shopping_bag_outlined,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Nama produk wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JenisProduksi>(
                  value: _jenisProduksi,
                  decoration: _buildDropdownDecoration(
                    label: 'Jenis Produksi',
                    icon: Icons.category_outlined,
                    hint: _jenisProduksi.deskripsi,
                  ),
                  items: JenisProduksi.values
                      .map((j) => DropdownMenuItem(
                            value: j,
                            child: Text(j.label,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _jenisProduksi = v!;
                      _hariKerjaController.text =
                          v.defaultHariKerjaBulan.toString();
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SkalaUsaha>(
                  value: _skalaUsaha,
                  decoration: _buildDropdownDecoration(
                    label: 'Skala Usaha',
                    icon: Icons.business_outlined,
                    hint: _skalaUsaha.deskripsi,
                  ),
                  items: SkalaUsaha.values
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.label,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _skalaUsaha = v!;
                      _profitMarginController.text =
                          v.rekomendasiProfitMargin.toString();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Setting Produksi', Icons.settings_outlined),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: [
                if (_jenisProduksi == JenisProduksi.batch) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          controller: _jumlahProduksiBatchController,
                          label: 'Produksi/Batch',
                          hint: '50',
                          icon: Icons.production_quantity_limits_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorFormatter()],
                          validator: (v) {
                            final clean =
                                v?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
                            final val = int.tryParse(clean);
                            return val == null || val <= 0 ? 'Harus > 0' : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          controller: _frekuensiBatchController,
                          label: 'Frekuensi Batch/Bulan',
                          hint: '4',
                          icon: Icons.repeat_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorFormatter()],
                          validator: (v) {
                            final clean =
                                v?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
                            final val = int.tryParse(clean);
                            return val == null || val <= 0 ? 'Harus > 0' : null;
                          },
                        ),
                      ),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          controller: _jumlahProduksiController,
                          label: 'Produksi/Hari',
                          hint: '1',
                          icon: Icons.production_quantity_limits_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorFormatter()],
                          validator: (v) {
                            final clean =
                                v?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
                            final val = int.tryParse(clean);
                            return val == null || val <= 0 ? 'Harus > 0' : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          controller: _hariKerjaController,
                          label: 'Hari Kerja/Bulan',
                          hint: '25',
                          icon: Icons.calendar_month_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorFormatter()],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _profitMarginController,
                  label: 'Profit Margin (%)',
                  hint:
                      'Rekomendasi: ${_skalaUsaha.rekomendasiProfitMargin.toStringAsFixed(0)}%',
                  icon: Icons.percent_rounded,
                  keyboardType: TextInputType.number,
                  suffixText: '%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTipBox(
            icon: Icons.lightbulb_outline_rounded,
            text:
                'Hitung HPP per produk secara terpisah. Alokasikan biaya bersama (overhead) secara proporsional sesuai volume produksi.',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STEP 2 – Komponen Biaya
  // ─────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle(
                    'Komponen Biaya', Icons.receipt_long_rounded),
              ),
              _buildAddButton(
                onPressed: () {
                  setState(() {
                    _komponenBiaya.add(KomponenBiaya(
                      id: _uuid.v4(),
                      nama: 'Komponen Baru',
                      nilai: 0,
                      periode: _jenisProduksi == JenisProduksi.batch
                          ? PeriodeKomponen.perBatch
                          : PeriodeKomponen.harian,
                    ));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._komponenBiaya.map((k) => KomponenBiayaInput(
                komponen: k,
                jenisProduksi: _jenisProduksi,
                onUpdate: (updated) {
                  setState(() {
                    final idx = _komponenBiaya.indexWhere((c) => c.id == updated.id);
                    if (idx != -1) _komponenBiaya[idx] = updated;
                  });
                },
                onDelete: () {
                  setState(() {
                    _komponenBiaya.removeWhere((c) => c.id == k.id);
                  });
                },
              )),
          const SizedBox(height: 16),
          _buildTipBox(
            icon: Icons.info_outline_rounded,
            text: _jenisProduksi == JenisProduksi.batch
                ? 'PER BATCH: Bahan baku, kemasan, tenaga kerja langsung\nMINGGUAN/BULANAN: Overhead (listrik, sewa, dll)\nCentang "Biaya Tetap" agar masuk ke analisis BEP.'
                : 'HARIAN: Bahan baku, upah harian\nBULANAN: Sewa, gaji, listrik\nCentang "Biaya Tetap" agar masuk ke analisis BEP.',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STEP 3 – Hasil HPP
  // ─────────────────────────────────────────────────────────
  Widget _buildStep3(HppCalculatorState state) {
    if (state is! HppCalculatorSuccess) {
      return _buildEmptyState(
        icon: Icons.calculate_outlined,
        title: 'Belum ada hasil',
        desc: 'Lengkapi informasi produk dan komponen biaya terlebih dahulu.',
        action: 'Kembali ke Komponen Biaya',
        onAction: () => _goToStep(1),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Hasil Perhitungan HPP', Icons.calculate_rounded),
          const SizedBox(height: 16),
          HppResultCard(calculation: state.calculation),
          const SizedBox(height: 20),
          // ── CTA 1: Analisis AI ──────────────────────────
          _buildAiCta(state),
          // ── CTA 2: Analisis Manual ──────────────────────
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _nextStep,
            icon: const Icon(Icons.analytics_outlined, size: 18),
            label: const Text('Analisis Manual (BEP & Profit)'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STEP 4 – Analisis
  // ─────────────────────────────────────────────────────────
  Widget _buildStep4(HppCalculatorState state) {
    if (state is! HppCalculatorSuccess) {
      return _buildEmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'Hitung HPP dulu',
        desc: 'Selesaikan langkah sebelumnya untuk melihat analisis BEP dan Profit.',
        action: 'Mulai dari Awal',
        onAction: () => _goToStep(0),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BEP Section
          _buildSectionTitle('Analisis Break Even Point', Icons.analytics_outlined),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFormField(
                  controller: _biayaTetapController,
                  label: 'Biaya Tetap Bulanan',
                  hint: 'Otomatis dari komponen tetap',
                  icon: Icons.attach_money_rounded,
                  prefixText: 'Rp ',
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorFormatter()],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _hitungBep,
                  icon: const Icon(Icons.analytics_rounded, size: 18),
                  label: const Text('Hitung BEP'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (state.bepAnalysis != null) ...[
            const SizedBox(height: 16),
            BepAnalysisCard(analysis: state.bepAnalysis!),
          ],
          const SizedBox(height: 24),
          // Profit Section
          _buildSectionTitle('Analisis Profit', Icons.trending_up_rounded),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFormField(
                  controller: _targetPenjualanController,
                  label: 'Target Penjualan (unit/bulan)',
                  hint: '0',
                  icon: Icons.bar_chart_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorFormatter()],
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controller: _investasiAwalController,
                  label: 'Investasi Awal (opsional)',
                  hint: 'Untuk menghitung ROI & payback period',
                  icon: Icons.account_balance_outlined,
                  prefixText: 'Rp ',
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorFormatter()],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _hitungProfit,
                  icon: const Icon(Icons.trending_up_rounded, size: 18),
                  label: const Text('Hitung Profit'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          if (state.profitAnalysis != null) ...[
            const SizedBox(height: 16),
            ProfitAnalysisCard(analysis: state.profitAnalysis!),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Bottom navigation bar
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 3;
    final isCompStep = _currentStep == 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton.icon(
              onPressed: _previousStep,
              icon:
                  const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Kembali'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (isCompStep) {
                  _hitungHpp();
                } else if (isLastStep) {
                  _navigateToShare();
                } else {
                  _nextStep();
                }
              },
              icon: Icon(
                isLastStep
                    ? Icons.ios_share_rounded
                    : isCompStep
                        ? Icons.calculate_rounded
                        : Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(
                isLastStep
                    ? 'Bagikan Hasil'
                    : isCompStep
                        ? 'Hitung HPP'
                        : 'Lanjut',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: isLastStep
                    ? AppColors.accent
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<dynamic>? inputFormatters,
    String? Function(String?)? validator,
    String? prefixText,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        prefixText: prefixText,
        suffixText: suffixText,
        suffixStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters?.cast(),
      validator: validator,
    );
  }

  InputDecoration _buildDropdownDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: hint,
      helperMaxLines: 2,
      prefixIcon: Icon(icon, size: 18),
    );
  }

  Widget _buildTipBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Tambah'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String desc,
    required String action,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 48, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCta(HppCalculatorSuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() => _showAiInsight = true);
            context.read<AiInsightViewModel>().analyze(
                  calculation: state.calculation,
                  bepAnalysis: state.bepAnalysis,
                  profitAnalysis: state.profitAnalysis,
                );
          },
          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
          label: const Text('✨  Analisis dengan AI'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Insight otomatis: skor kesehatan bisnis, masalah kritis & rekomendasi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        if (_showAiInsight) ...[
          const SizedBox(height: 16),
          AiInsightCard(
            calculation: state.calculation,
            bepAnalysis: state.bepAnalysis,
            profitAnalysis: state.profitAnalysis,
          ),
        ],
      ],
    );
  }
}
