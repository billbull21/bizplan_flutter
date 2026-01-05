import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'src/router/app_router.dart';

void main() async {
  usePathUrlStrategy(); // Hilangkan # dari URL
  await initializeDateFormatting('id_ID');
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kalkulator HPP Pro | Obizplan',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      routerConfig: AppRouter.router,
    );
  }
}
