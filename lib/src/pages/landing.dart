import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'template_list.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final api = ApiClient();
  List<dynamic> cats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    api.categories().then((v) {
      setState(() { cats = v; loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kategori')),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          for (final c in cats)
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TemplateListPage(categorySlug: c['slug']),
                  ));
                },
                child: Center(child: Text(c['name'])),
              ),
            )
        ],
      ),
    );
  }
}
