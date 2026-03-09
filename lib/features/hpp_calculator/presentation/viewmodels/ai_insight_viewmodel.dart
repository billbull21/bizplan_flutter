import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/ai_insight_service.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../domain/entities/profit_analysis.dart';
import 'ai_insight_state.dart';

class AiInsightViewModel extends Cubit<AiInsightState> {
  final _service = AiInsightService();

  AiInsightViewModel() : super(const AiInsightInitial());

  Future<void> analyze({
    required HppCalculation calculation,
    BepAnalysis? bepAnalysis,
    ProfitAnalysis? profitAnalysis,
  }) async {
    if (state is AiInsightLoading) return;
    emit(const AiInsightLoading());
    try {
      final insight = await _service.analyze(
        calculation: calculation,
        bepAnalysis: bepAnalysis,
        profitAnalysis: profitAnalysis,
      );
      emit(AiInsightSuccess(insight));
    } catch (e) {
      emit(AiInsightError(_parseError(e)));
    }
  }

  void reset() => emit(const AiInsightInitial());

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('401')) return 'API Key tidak valid. Cek konfigurasi.';
    if (msg.contains('429')) return 'Rate limit. Coba beberapa saat lagi.';
    if (msg.contains('SocketException') || msg.contains('connection')) {
      return 'Tidak ada koneksi internet.';
    }
    return 'Gagal memuat analisis AI. Coba lagi.';
  }
}
