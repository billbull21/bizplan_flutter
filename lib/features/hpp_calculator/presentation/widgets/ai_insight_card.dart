import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../domain/entities/profit_analysis.dart';
import '../viewmodels/ai_insight_state.dart';
import '../viewmodels/ai_insight_viewmodel.dart';

class AiInsightCard extends StatelessWidget {
  final HppCalculation calculation;
  final BepAnalysis? bepAnalysis;
  final ProfitAnalysis? profitAnalysis;

  const AiInsightCard({
    super.key,
    required this.calculation,
    this.bepAnalysis,
    this.profitAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiInsightViewModel, AiInsightState>(
      builder: (context, state) {
        if (state is AiInsightInitial) {
          return _buildInitialCard(context);
        }
        if (state is AiInsightLoading) {
          return _buildLoadingCard();
        }
        if (state is AiInsightError) {
          return _buildErrorCard(context, state.message);
        }
        if (state is AiInsightSuccess) {
          return _buildInsightContent(context, state.insight);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInitialCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisis AI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Insight bisnis dari AI untuk "racikan" kamu',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<AiInsightViewModel>().analyze(
                  calculation: calculation,
                  bepAnalysis: bepAnalysis,
                  profitAnalysis: profitAnalysis,
                ),
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: const Text('Analisis Bisnisku'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI sedang menganalisis bisnis kamu...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Memproses HPP, margin, dan komponen biaya',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            backgroundColor: Color(0xFFE0E7FF),
            valueColor:
                AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => context.read<AiInsightViewModel>().analyze(
                  calculation: calculation,
                  bepAnalysis: bepAnalysis,
                  profitAnalysis: profitAnalysis,
                ),
            child: const Text('Coba Lagi',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightContent(BuildContext context, AiInsight insight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header + skor
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Analisis AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Skor
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Skor Kesehatan',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 10)),
                  Text(
                    '${insight.skorKesehatan}/100',
                    style: TextStyle(
                      color: _skorColor(insight.skorKesehatan),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Ringkasan
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.summarize_rounded,
                  size: 16, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.ringkasan,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3730A3),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Insights list
        ...insight.insights.map((item) => _buildInsightItem(item)),
        // Refresh
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            context.read<AiInsightViewModel>().reset();
            // Re-trigger immediately
            context.read<AiInsightViewModel>().analyze(
              calculation: calculation,
              bepAnalysis: bepAnalysis,
              profitAnalysis: profitAnalysis,
            );
          },
          icon: const Icon(Icons.refresh_rounded, size: 14),
          label: const Text('Analisis Ulang'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(InsightItem item) {
    final cfg = _levelConfig(item.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cfg.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_kategoriIcon(item.kategori),
                  size: 14, color: cfg.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.judul,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cfg.color,
                  ),
                ),
              ),
              _buildLevelBadge(item.level, cfg),
            ],
          ),
          if (item.detail.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.detail,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (item.rekomendasi.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cfg.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded,
                      size: 12, color: cfg.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.rekomendasi,
                      style: TextStyle(
                        fontSize: 12,
                        color: cfg.color,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelBadge(InsightLevel level, _LevelConfig cfg) {
    final label = switch (level) {
      InsightLevel.success => '✓ Bagus',
      InsightLevel.warning => '⚠ Perhatian',
      InsightLevel.danger => '✗ Kritis',
      InsightLevel.info => 'ℹ Info',
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cfg.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: cfg.color,
        ),
      ),
    );
  }

  Color _skorColor(int skor) {
    if (skor >= 75) return const Color(0xFF4ADE80);
    if (skor >= 50) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  IconData _kategoriIcon(InsightKategori kategori) {
    return switch (kategori) {
      InsightKategori.biaya => Icons.receipt_rounded,
      InsightKategori.harga => Icons.sell_rounded,
      InsightKategori.produksi => Icons.factory_rounded,
      InsightKategori.profit => Icons.trending_up_rounded,
      InsightKategori.umum => Icons.lightbulb_rounded,
    };
  }

  _LevelConfig _levelConfig(InsightLevel level) {
    return switch (level) {
      InsightLevel.success => _LevelConfig(
          color: const Color(0xFF059669),
          bg: const Color(0xFFF0FDF4),
          border: const Color(0xFFBBF7D0),
        ),
      InsightLevel.warning => _LevelConfig(
          color: const Color(0xFFD97706),
          bg: const Color(0xFFFFFBEB),
          border: const Color(0xFFFDE68A),
        ),
      InsightLevel.danger => _LevelConfig(
          color: const Color(0xFFDC2626),
          bg: const Color(0xFFFEF2F2),
          border: const Color(0xFFFECACA),
        ),
      InsightLevel.info => _LevelConfig(
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFEFF6FF),
          border: const Color(0xFFBFDBFE),
        ),
    };
  }
}

class _LevelConfig {
  final Color color;
  final Color bg;
  final Color border;
  const _LevelConfig(
      {required this.color, required this.bg, required this.border});
}
