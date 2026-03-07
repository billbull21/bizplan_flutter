import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class ObizplanApp extends StatelessWidget {
  const ObizplanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Obizplan – Kalkulator HPP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}
