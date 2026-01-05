import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/komponen_biaya.dart';
import '../../domain/entities/periode_komponen.dart';
import '../../utils/thousands_separator_input_formatter_utils.dart';

class KomponenBiayaInput extends StatefulWidget {
  final KomponenBiaya komponen;
  final Function(KomponenBiaya) onUpdate;
  final VoidCallback onDelete;

  const KomponenBiayaInput({
    super.key,
    required this.komponen,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<KomponenBiayaInput> createState() => _KomponenBiayaInputState();
}

class _KomponenBiayaInputState extends State<KomponenBiayaInput> {
  late TextEditingController _namaController;
  late TextEditingController _nilaiController;
  late PeriodeKomponen _periode;
  final NumberFormat _numberFormat = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.komponen.nama);
    _nilaiController = TextEditingController(
      text: widget.komponen.nilai > 0 ? _numberFormat.format(widget.komponen.nilai.toInt()) : '',
    );
    _periode = widget.komponen.periode;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nilaiController.dispose();
    super.dispose();
  }

  void _updateKomponen() {
    final nilai = double.tryParse(_nilaiController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    widget.onUpdate(
      widget.komponen.copyWith(
        nama: _namaController.text,
        nilai: nilai,
        periode: _periode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Komponen',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _updateKomponen(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nilaiController,
                    decoration: const InputDecoration(
                      labelText: 'Nilai',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      ThousandsSeparatorInputFormatterUtils(),
                    ],
                    onChanged: (_) => _updateKomponen(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<PeriodeKomponen>(
                    value: _periode,
                    decoration: const InputDecoration(
                      labelText: 'Periode',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: PeriodeKomponen.values.map((periode) {
                      return DropdownMenuItem(
                        value: periode,
                        child: Text(periode.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _periode = value!;
                        _updateKomponen();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
