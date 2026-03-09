import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/thousands_separator_formatter.dart';
import '../../domain/entities/jenis_produksi.dart';
import '../../domain/entities/komponen_biaya.dart';
import '../../domain/entities/periode_komponen.dart';

class KomponenBiayaInput extends StatefulWidget {
  final KomponenBiaya komponen;
  final JenisProduksi jenisProduksi;
  final Function(KomponenBiaya) onUpdate;
  final VoidCallback onDelete;

  const KomponenBiayaInput({
    super.key,
    required this.komponen,
    required this.jenisProduksi,
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
  late bool _isTetap;
  final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.komponen.nama);
    _nilaiController = TextEditingController(
      text: widget.komponen.nilai > 0
          ? _formatter.format(widget.komponen.nilai.toInt())
          : '',
    );
    // Pastikan _periode valid untuk jenisProduksi saat ini
    // (misal: komponen default 'harian' tapi user sudah pilih mode batch)
    final validOptions = _periodeOptions;
    _periode = validOptions.contains(widget.komponen.periode)
        ? widget.komponen.periode
        : validOptions.first;
    _isTetap = widget.komponen.isTetap;
    // Jika periode dikoreksi, propagate ke parent setelah frame pertama
    if (_periode != widget.komponen.periode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateKomponen());
    }
  }

  @override
  void didUpdateWidget(covariant KomponenBiayaInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jenisProduksi != widget.jenisProduksi) {
      final valid = _periodeOptions;
      if (!valid.contains(_periode)) {
        setState(() {
          _periode = valid.first;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateKomponen());
      }
    }
  }

  List<PeriodeKomponen> get _periodeOptions {
    if (widget.jenisProduksi == JenisProduksi.batch) {
      return [PeriodeKomponen.perBatch, PeriodeKomponen.mingguan, PeriodeKomponen.bulanan];
    }
    return [PeriodeKomponen.harian, PeriodeKomponen.mingguan, PeriodeKomponen.bulanan];
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nilaiController.dispose();
    super.dispose();
  }

  void _updateKomponen() {
    final nilai = double.tryParse(
            _nilaiController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;
    widget.onUpdate(
      widget.komponen.copyWith(
        nama: _namaController.text,
        nilai: nilai,
        periode: _periode,
        isTetap: _isTetap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isTetap
              ? AppColors.warning.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isTetap ? AppColors.warning : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _namaController,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Nama komponen biaya',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => _updateKomponen(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.textTertiary,
                  onPressed: widget.onDelete,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Hapus komponen',
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          // Input row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nilaiController,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                      prefixText: 'Rp ',
                      prefixStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorFormatter()],
                    onChanged: (_) => _updateKomponen(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<PeriodeKomponen>(
                    value: _periodeOptions.contains(_periode)
                        ? _periode
                        : _periodeOptions.first,
                    isDense: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                    ),
                    items: _periodeOptions.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.label,
                            style: const TextStyle(fontSize: 13)),
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
          ),
          // Biaya tetap toggle
          InkWell(
            onTap: () {
              setState(() {
                _isTetap = !_isTetap;
                _updateKomponen();
              });
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isTetap
                    ? AppColors.warningContainer
                    : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _isTetap,
                      onChanged: (value) {
                        setState(() {
                          _isTetap = value ?? false;
                          _updateKomponen();
                        });
                      },
                      activeColor: AppColors.warning,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isTetap ? 'Biaya Tetap (masuk ke BEP)' : 'Biaya Variabel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _isTetap ? FontWeight.w600 : FontWeight.w400,
                      color:
                          _isTetap ? AppColors.warning : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (_isTetap)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TETAP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
