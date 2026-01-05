import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../pages/hpp_calculator_page.dart';
import '../presentation/pages/stepper_hpp_calculator_page.dart';
import '../presentation/pages/hpp_share_page.dart';
import '../presentation/cubits/hpp_calculator_cubit.dart';
import '../domain/entities/hpp_calculation.dart';
import '../domain/entities/bep_analysis.dart';
import '../domain/entities/profit_analysis.dart';

class AppRouter {
  static const String home = '/';
  static const String calculatorSimple = '/calculator-simple';
  static const String calculatorPro = '/calculator-pro';
  static const String share = '/share';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: calculatorSimple,
        name: 'calculator-simple',
        builder: (context, state) => const HppCalculatorPage(),
      ),
      GoRoute(
        path: calculatorPro,
        name: 'calculator-pro',
        builder: (context, state) => BlocProvider(
          create: (context) => HppCalculatorCubit(),
          child: const StepperHppCalculatorPage(),
        ),
      ),
      GoRoute(
        path: share,
        name: 'share',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return HppSharePage(
            calculation: extra?['calculation'] as HppCalculation,
            bepAnalysis: extra?['bepAnalysis'] as BepAnalysis?,
            profitAnalysis: extra?['profitAnalysis'] as ProfitAnalysis?,
          );
        },
      ),
    ],
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator HPP Pro'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.rocket_launch, size: 64, color: Colors.blue.shade700),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Mode Kalkulator',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gunakan kalkulator sesuai kebutuhan Anda',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildModeCard(
              context,
              title: '🆕 Kalkulator Pro',
              subtitle: 'Fitur lengkap dengan BEP & Profit Analysis',
              features: [
                'Step-by-step wizard',
                'Komponen biaya harian/bulanan',
                'Analisis Break Even Point',
                'Proyeksi profit & ROI',
              ],
              color: Colors.green,
              onTap: () => context.go(AppRouter.calculatorPro),
            ),
            const SizedBox(height: 16),
            _buildModeCard(
              context,
              title: '📱 Kalkulator Simple',
              subtitle: 'Mode sederhana untuk perhitungan cepat',
              features: [
                'Antarmuka sederhana',
                'Perhitungan HPP dasar',
                'Simpan template',
                'Cocok untuk pemula',
              ],
              color: Colors.blue,
              onTap: () => context.go(AppRouter.calculatorSimple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<String> features,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calculate, color: color, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: color),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
