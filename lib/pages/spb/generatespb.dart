// lib/pages/panen/docket_spb_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/spb/spb_docket_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import 'package:flutter_application_3/utils/bluetooth_helper.dart';
// pastikan path provider benar:

class DocketSPBPage extends StatelessWidget {
  final String? noTrans;

  const DocketSPBPage({super.key, this.noTrans});

  @override
  Widget build(BuildContext context) {
    final spbNo = noTrans ?? '';
    return ChangeNotifierProvider(
      create: (_) => SpbDocketProvider(cetakCounter: 2)..prepare(spbNo),
      child: const _DocketBody(),
    );
  }
}

class _DocketBody extends StatelessWidget {
  const _DocketBody();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SpbDocketProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Print QR')),
      body: Builder(
        builder: (context) {
          if (p.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  p.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text('DOCKET',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  p.notransaksi,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),

                // QR format legacy: *...$
                QrImageView(
                  data: p.qrLegacy.isEmpty ? '-' : p.qrLegacy,
                  size: 200,
                  backgroundColor: Colors.white,
                ),

                const SizedBox(height: 16),
                _kv('Tanggal', p.tanggal),
                _kv('Driver', p.driver),
                _kv('Nopol', p.nopol),
                // _kv('Estate', p.estate),
                // _kv('Divisi', p.divisi),
                _kv('Divisi', "${p.estate}${p.divisi}"),
                _kv('PKS Tujuan', p.penerimaTbs),
                _kv('Cetakan', p.cetakanVersi.toString()),
                _kv('Total JJG', p.jjgTotal.toString()),
                _kv('Total Brd', p.brondolanTotal.toString()),
                // if (p.tahunTanamCSV.isNotEmpty) _kv('TT', p.tahunTanamCSV),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      await _printDocket(context, p);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(k)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  /// Cetak ke Bluetooth printer:
  /// - Judul + ringkasan header
  /// - QR (pakai p.qrLegacy → *...$)
  /// - Ringkas dataPrintSpb (agar ada jejak informasi lengkap)
  Future<void> _printDocket(BuildContext context, SpbDocketProvider p) async {
    try {
      final helper = BluetoothHelper();
      final savedAddress = await helper.getSavedPrinterAddress();
      if (savedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum ada printer yang disimpan.')),
        );
        return;
      }

      // Cari perangkat yang sudah paired
      final devices = await helper.getBondedDevices();
      final targetPrinter = devices.firstWhere(
        (d) => d.address == savedAddress,
        orElse: () => throw Exception("Printer tidak ditemukan"),
      );

      await helper.connectToPrinter(targetPrinter);
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate bytes ESC/POS
      final profile = await CapabilityProfile.load(name: 'default');
      final generator = Generator(PaperSize.mm58, profile);
      final List<int> bytes = [];

      // Header
      bytes.addAll(generator.text(
        'SPB',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      ));

      bytes.addAll(generator.text(p.notransaksi,
          styles: const PosStyles(align: PosAlign.center)));
      bytes.addAll(generator.hr());

      // QR code (pakai format legacy *...$)
      if (p.qrLegacy.isNotEmpty) {
        bytes.addAll(generator.qrcode(
          p.qrLegacy,
          size: QRSize.size7,
          align: PosAlign.center,
        ));
        bytes.addAll(generator.feed(1));
      }

      // Ringkasan
      bytes.addAll(generator.text('Tanggal : ${p.tanggal}'));
      bytes.addAll(generator.text('Driver  : ${p.driver}'));
      bytes.addAll(generator.text('Nopol   : ${p.nopol}'));
      // bytes.addAll(generator.text('Estate  : ${p.estate}'));
      bytes.addAll(generator.text('Divisi  : ${p.estate}${p.divisi}'));
      bytes.addAll(generator.text('PKS Tujuan  : ${p.penerimaTbs}'));
      bytes.addAll(generator.text('Cetakan : ${p.cetakanVersi}'));
      bytes.addAll(generator.text('Total Jjg : ${p.jjgTotal}'));
      bytes.addAll(generator.text('Total Brondolan : ${p.brondolanTotal}'));
      // if (p.tahunTanamCSV.isNotEmpty) {
      //   bytes.addAll(generator.text('TT      : ${p.tahunTanamCSV}'));
      // }
      bytes.addAll(generator.hr());

      // Ringkas detail panjang (opsional)
      final detail = p.dataPrintSpb;
      final maxChars = 500; // biar aman untuk kertas kecil
      final safeDetail = detail.length > maxChars
          ? "${detail.substring(0, maxChars)}..."
          : detail;

      // bytes.addAll(generator.text('Detail:'));
      // bytes.addAll(generator.text(safeDetail));
      // bytes.addAll(generator.feed(3));

      // Kirim ke printer
      await BlueThermalPrinter.instance.writeBytes(Uint8List.fromList(bytes));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Print terkirim.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal print: $e')),
        );
      }
    }
  }
}
