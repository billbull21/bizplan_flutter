import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'template_detail.dart';

class TemplateListPage extends StatefulWidget {
  final String categorySlug;
  const TemplateListPage({super.key, required this.categorySlug});

  @override
  State<TemplateListPage> createState() => _TemplateListPageState();
}

class _TemplateListPageState extends State<TemplateListPage> {
  final api = ApiClient();
  List<dynamic> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    api.templates(widget.categorySlug).then((v) {
      setState(() { items = v; loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('Templates: ${widget.categorySlug}')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final t = items[i];
          return ListTile(
            title: Text(t['name']),
            subtitle: Text('Batch: ${t['batch_units']}, Waste: ${(t['waste_pct']*100).toStringAsFixed(1)}%'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => TemplateDetailPage(id: t['id']),
            )),
          );
        },
      ),
    );
  }
}
