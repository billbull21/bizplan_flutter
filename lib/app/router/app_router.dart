import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/hpp_calculator/domain/entities/bep_analysis.dart';
import '../../features/hpp_calculator/domain/entities/hpp_calculation.dart';
import '../../features/hpp_calculator/domain/entities/profit_analysis.dart';
import '../../features/hpp_calculator/presentation/viewmodels/hpp_calculator_viewmodel.dart';
import '../../features/hpp_calculator/presentation/views/hpp_calculator_view.dart';
import '../../features/hpp_calculator/presentation/views/hpp_share_view.dart';

class AppRouter {
  static const String calculator = '/';
  static const String share = '/share';

  static final GoRouter router = GoRouter(
    initialLocation: calculator,
    routes: [
      GoRoute(
        path: calculator,
        name: 'calculator',
        builder: (context, state) => BlocProvider(
          create: (_) => HppCalculatorViewModel(),
          child: const HppCalculatorView(),
        ),
      ),
      GoRoute(
        path: share,
        name: 'share',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return HppShareView(
            calculation: extra['calculation'] as HppCalculation,
            bepAnalysis: extra['bepAnalysis'] as BepAnalysis?,
            profitAnalysis: extra['profitAnalysis'] as ProfitAnalysis?,
          );
        },
      ),
    ],
  );
}
