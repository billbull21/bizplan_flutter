import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'configurator.dart';

class TemplateDetailPage extends StatefulWidget {
  final String id;
  const TemplateDetailPage({super.key, required this.id});

  @override
  State<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends State<TemplateDetailPage> {
  final api = ApiClient();
  Map<String, dynamic>? t;

  @override
  void initState() {
    super.initState();
    api.templateDetail(widget.id).then((v) => setState(() => t = v));
  }

  @override
  Widget build(BuildContext context) {
    if (t == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final mats = (t!['materials'] as List).cast<Map>();
    final lab = (t!['labor'] as List).cast<Map>();
    final oh = (t!['overhead'] as List).cast<Map>();
    return Scaffold(
      appBar: AppBar(title: Text(t!['name'])),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Batch Units: ${t!['batch_units']}'),
          Text('Waste: ${(t!['waste_pct']*100).toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          const Text('Materials', style: TextStyle(fontWeight: FontWeight.bold)),
          ...mats.map((m) => Text('- ${m['name']}: ${m['qty']} ${m['unit']} @ ${m['price_per_unit']}')).toList(),
          const SizedBox(height: 12),
          const Text('Labor', style: TextStyle(fontWeight: FontWeight.bold)),
          ...lab.map((l) => Text('- ${l['role']}: ${l['hours']}h @ ${l['hourly_rate']}')).toList(),
          const SizedBox(height: 12),
          const Text('Overhead', style: TextStyle(fontWeight: FontWeight.bold)),
          ...oh.map((o) => Text('- ${o['name']}: ${o['cost']}')).toList(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ConfiguratorPage(template: t!),
              ));
            },
            child: const Text('Use this template'),
          )
        ],
      ),
    );
  }
}
