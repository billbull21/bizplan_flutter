import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/komponen_biaya.dart';
import '../../domain/entities/skala_usaha.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../domain/entities/profit_analysis.dart';
import 'hpp_calculator_state.dart';

class HppCalculatorCubit extends Cubit<HppCalculatorState> {
  final _uuid = const Uuid();

  HppCalculatorCubit() : super(const HppCalculatorInitial());

  /// Hitung HPP dari input user
  void calculateHpp({
    required String namaProduk,
    required SkalaUsaha skalaUsaha,
    required SettingProduksi settingProduksi,
    required List<KomponenBiaya> komponenBiaya,
    required double profitMargin,
  }) {
    try {
      emit(const HppCalculatorCalculating());

      final calculation = HppCalculation(
        id: _uuid.v4(),
        namaProduk: namaProduk,
        skalaUsaha: skalaUsaha,
        settingProduksi: settingProduksi,
        komponenBiaya: komponenBiaya,
        profitMargin: profitMargin,
        createdAt: DateTime.now(),
      );

      emit(HppCalculatorSuccess(calculation: calculation));
    } catch (e) {
      emit(HppCalculatorError('Gagal menghitung HPP: ${e.toString()}'));
    }
  }

  /// Hitung BEP Analysis
  void calculateBep({
    required double biayaTetapBulanan,
    required double biayaVariabelPerUnit,
    required double hargaJualPerUnit,
    required int produksiPerHari,
    int hariKerjaBulan = 25,
  }) {
    final currentState = state;
    if (currentState is! HppCalculatorSuccess) {
      emit(const HppCalculatorError('Hitung HPP terlebih dahulu'));
      return;
    }

    try {
      final bepAnalysis = BepAnalysis(
        biayaTetapBulanan: biayaTetapBulanan,
        biayaVariabelPerUnit: biayaVariabelPerUnit,
        hargaJualPerUnit: hargaJualPerUnit,
        produksiPerHari: produksiPerHari,
        hariKerjaBulan: hariKerjaBulan,
      );

      if (!bepAnalysis.isViable) {
        emit(HppCalculatorError(
            bepAnalysis.validationMessage ?? 'Model bisnis tidak viable'));
        return;
      }

      emit(currentState.copyWith(bepAnalysis: bepAnalysis));
    } catch (e) {
      emit(HppCalculatorError('Gagal menghitung BEP: ${e.toString()}'));
    }
  }

  /// Hitung Profit Analysis
  void calculateProfitAnalysis({
    required double hppPerUnit,
    required double hargaJualPerUnit,
    required int jumlahProduksi,
    required int targetPenjualan,
    required double biayaTetapBulanan,
    double? investasiAwal,
  }) {
    final currentState = state;
    if (currentState is! HppCalculatorSuccess) {
      emit(const HppCalculatorError('Hitung HPP terlebih dahulu'));
      return;
    }

    try {
      final profitAnalysis = ProfitAnalysis(
        hppPerUnit: hppPerUnit,
        hargaJualPerUnit: hargaJualPerUnit,
        jumlahProduksi: jumlahProduksi,
        targetPenjualan: targetPenjualan,
        biayaTetapBulanan: biayaTetapBulanan,
        investasiAwal: investasiAwal,
      );

      emit(currentState.copyWith(profitAnalysis: profitAnalysis));
    } catch (e) {
      emit(HppCalculatorError('Gagal menghitung profit: ${e.toString()}'));
    }
  }

  /// Reset calculation
  void reset() {
    emit(const HppCalculatorInitial());
  }

  /// Update profit margin
  void updateProfitMargin(double newMargin) {
    final currentState = state;
    if (currentState is! HppCalculatorSuccess) return;

    final updatedCalculation =
        currentState.calculation.copyWith(profitMargin: newMargin);
    emit(currentState.copyWith(calculation: updatedCalculation));
  }

  /// Update komponen biaya
  void updateKomponenBiaya(List<KomponenBiaya> komponenBiaya) {
    final currentState = state;
    if (currentState is! HppCalculatorSuccess) return;

    final updatedCalculation =
        currentState.calculation.copyWith(komponenBiaya: komponenBiaya);
    emit(currentState.copyWith(calculation: updatedCalculation));
  }
}
