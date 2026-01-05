import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/hpp_calculation.dart';
import '../../domain/entities/bep_analysis.dart';
import '../../domain/entities/profit_analysis.dart';
import '../../domain/entities/periode_komponen.dart';

class HppSharePage extends StatefulWidget {
  final HppCalculation calculation;
  final BepAnalysis? bepAnalysis;
  final ProfitAnalysis? profitAnalysis;

  const HppSharePage({
    super.key,
    required this.calculation,
    this.bepAnalysis,
    this.profitAnalysis,
  });

  @override
  State<HppSharePage> createState() => _HppSharePageState();
}

class _HppSharePageState extends State<HppSharePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  bool _isSharing = false;

  Future<void> _shareAsImage() async {
    setState(() => _isSharing = true);

    try {
      // Capture screenshot
      final Uint8List? image = await _screenshotController.capture();
      
      if (image != null) {
        // Save to temp file
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/hpp_calculation_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        // Share
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Hasil Perhitungan HPP - ${widget.calculation.namaProduk}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal share: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep HPP'),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.share),
            onPressed: _isSharing ? null : _shareAsImage,
            tooltip: 'Share sebagai gambar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Screenshot(
            controller: _screenshotController,
            child: _buildShareCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildShareCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 RESEP HPP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.calculation.namaProduk,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HPP Section
                _buildSection(
                  '💰 Harga Pokok Produksi',
                  [
                    _buildInfoRow('Total Biaya/Hari', _currencyFormat.format(widget.calculation.totalBiaya)),
                    _buildInfoRow('Produksi/Hari', '${widget.calculation.settingProduksi.jumlahProduksiPerHari} unit'),
                    const Divider(height: 24),
                    _buildHighlight('HPP per Unit', _currencyFormat.format(widget.calculation.hppPerUnit)),
                  ],
                ),

                const SizedBox(height: 20),

                // Profit Margin
                _buildSection(
                  '📈 Harga Jual',
                  [
                    _buildInfoRow('Profit Margin', '${widget.calculation.profitMargin.toStringAsFixed(1)}%'),
                    const Divider(height: 24),
                    _buildHighlight('Harga Jual', _currencyFormat.format(widget.calculation.hargaJualPerUnit)),
                    _buildInfoRow('Profit/Unit', _currencyFormat.format(widget.calculation.profitPerUnit)),
                  ],
                ),

                // BEP Section
                if (widget.bepAnalysis != null) ...[
                  const SizedBox(height: 20),
                  _buildSection(
                    '🎯 Break Even Point',
                    [
                      _buildInfoRow('BEP Unit', '${widget.bepAnalysis!.bepUnit.toStringAsFixed(0)} unit/bulan'),
                      _buildInfoRow('BEP Rupiah', _currencyFormat.format(widget.bepAnalysis!.bepRupiah)),
                      _buildInfoRow('Waktu BEP', '${widget.bepAnalysis!.bepHari.toStringAsFixed(1)} hari'),
                    ],
                  ),
                ],

                // Profit Analysis
                if (widget.profitAnalysis != null) ...[
                  const SizedBox(height: 20),
                  _buildSection(
                    '💹 Analisis Profit',
                    [
                      _buildInfoRow('Gross Profit', _currencyFormat.format(widget.profitAnalysis!.totalGrossProfit)),
                      _buildInfoRow('Net Profit', _currencyFormat.format(widget.profitAnalysis!.netProfit)),
                      _buildInfoRow('ROI', '${widget.profitAnalysis!.roi.toStringAsFixed(1)}%'),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // Komponen Biaya
                _buildSection(
                  '📝 Rincian Biaya',
                  [
                    ...widget.calculation.komponenBiaya.map((k) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                k.nama,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              _currencyFormat.format(k.nilai),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: k.isTetap ? Colors.orange.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                k.periode.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: k.isTetap ? Colors.orange.shade700 : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 20),

                // Footer
                Center(
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Dibuat dengan BizPlan HPP Calculator',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlight(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
