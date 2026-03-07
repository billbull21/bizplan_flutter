import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';

void main() async {
  usePathUrlStrategy();
  await initializeDateFormatting('id_ID');
  runApp(const ObizplanApp());
}
