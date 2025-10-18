import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ConfiguratorPage extends StatefulWidget {
  final Map<String, dynamic> template;
  const ConfiguratorPage({super.key, required this.template});

  @override
  State<ConfiguratorPage> createState() => _ConfiguratorPageState();
}

class _ConfiguratorPageState extends State<ConfiguratorPage> {
  final api = ApiClient();
  late Map<String, dynamic> payload;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    payload = {
      'batch_units': widget.template['batch_units'],
      'waste_pct': widget.template['waste_pct'],
      'fees_payment_pct': widget.template['fees_payment_pct'],
      'fees_marketplace_pct': widget.template['fees_marketplace_pct'],
      'tax_ppn_pct': widget.template['tax_ppn_pct'],
      'tax_enabled': widget.template['tax_enabled'],
      'materials': List<Map<String, dynamic>>.from(widget.template['materials']),
      'labor': List<Map<String, dynamic>>.from(widget.template['labor']),
      'overhead': List<Map<String, dynamic>>.from(widget.template['overhead']),
    };
  }

  void _recalculate() async {
    final r = await api.calcHpp(payload);
    setState(() => result = r);
  }

  @override
  Widget build(BuildContext context) {
    final materials = (payload['materials'] as List).cast<Map<String, dynamic>>();
    return Scaffold(
      appBar: AppBar(title: const Text('Configurator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: _numField('Batch Units', payload['batch_units'].toString(), (v) {
              payload['batch_units'] = int.tryParse(v) ?? payload['batch_units'];
            })),
            const SizedBox(width: 12),
            Expanded(child: _numField('Waste %', (payload['waste_pct']*100).toStringAsFixed(2), (v) {
              final pct = double.tryParse(v) ?? (payload['waste_pct']*100);
              payload['waste_pct'] = pct/100.0;
            })),
          ]),
          const SizedBox(height: 16),
          const Text('Materials', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (int i=0;i<materials.length;i++)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(materials[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: [
                      Expanded(child: _numField('Qty', materials[i]['qty'].toString(), (v){
                        materials[i]['qty'] = double.tryParse(v) ?? materials[i]['qty'];
                      })),
                      const SizedBox(width: 8),
                      Expanded(child: _numField('Price/Unit', materials[i]['price_per_unit'].toString(), (v){
                        materials[i]['price_per_unit'] = double.tryParse(v) ?? materials[i]['price_per_unit'];
                      })),
                    ]),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _recalculate, child: const Text('Recalculate')),
          const SizedBox(height: 12),
          if (result != null) ...[
            Text('Units out: ${result!['units_out']}'),
            Text('HPP/Unit: ${result!['hpp_per_unit'].toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Budget: ${result!['price_bands']['budget']['price_from'].toStringAsFixed(0)} - ${result!['price_bands']['budget']['price_to'].toStringAsFixed(0)}'),
            Text('Mid: ${result!['price_bands']['mid']['price_from'].toStringAsFixed(0)} - ${result!['price_bands']['mid']['price_to'].toStringAsFixed(0)}'),
            Text('Premium: ${result!['price_bands']['premium']['price_from'].toStringAsFixed(0)} - ${result!['price_bands']['premium']['price_to'].toStringAsFixed(0)}'),
          ]
        ],
      ),
    );
  }

  Widget _numField(String label, String initial, void Function(String) onChanged) {
    final ctrl = TextEditingController(text: initial);
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: onChanged,
    );
  }
}
