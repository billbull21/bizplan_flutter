import 'package:equatable/equatable.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../domain/entities/profit_analysis.dart';

/// Base state untuk HPP Calculator
abstract class HppCalculatorState extends Equatable {
  const HppCalculatorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HppCalculatorInitial extends HppCalculatorState {
  const HppCalculatorInitial();
}

/// State ketika sedang menghitung
class HppCalculatorCalculating extends HppCalculatorState {
  const HppCalculatorCalculating();
}

/// State ketika berhasil menghitung
class HppCalculatorSuccess extends HppCalculatorState {
  final HppCalculation calculation;
  final BepAnalysis? bepAnalysis;
  final ProfitAnalysis? profitAnalysis;

  const HppCalculatorSuccess({
    required this.calculation,
    this.bepAnalysis,
    this.profitAnalysis,
  });

  HppCalculatorSuccess copyWith({
    HppCalculation? calculation,
    BepAnalysis? bepAnalysis,
    ProfitAnalysis? profitAnalysis,
  }) {
    return HppCalculatorSuccess(
      calculation: calculation ?? this.calculation,
      bepAnalysis: bepAnalysis ?? this.bepAnalysis,
      profitAnalysis: profitAnalysis ?? this.profitAnalysis,
    );
  }

  @override
  List<Object?> get props => [calculation, bepAnalysis, profitAnalysis];
}

/// State ketika error
class HppCalculatorError extends HppCalculatorState {
  final String message;

  const HppCalculatorError(this.message);

  @override
  List<Object?> get props => [message];
}
