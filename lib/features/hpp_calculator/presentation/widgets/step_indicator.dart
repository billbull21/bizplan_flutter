import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget indikator langkah-langkah pada kalkulator
class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.currentStep,
  });

  static const _steps = [
    (label: 'Info', icon: Icons.info_outline_rounded),
    (label: 'Biaya', icon: Icons.receipt_long_rounded),
    (label: 'HPP', icon: Icons.calculate_rounded),
    (label: 'Analisis', icon: Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            _buildStep(i, _steps[i].label, _steps[i].icon),
            if (i < _steps.length - 1) _buildConnector(i),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(int index, String label, IconData icon) {
    final isActive = currentStep == index;
    final isCompleted = currentStep > index;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.accent
                  : isActive
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
              border: isActive
                  ? null
                  : isCompleted
                      ? null
                      : Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              size: 18,
              color: isCompleted || isActive
                  ? AppColors.textOnPrimary
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isCompleted
                  ? AppColors.accent
                  : isActive
                      ? AppColors.primary
                      : AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int afterIndex) {
    final isCompleted = currentStep > afterIndex;
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: isCompleted ? AppColors.accent : AppColors.border,
        ),
      ),
    );
  }
}
