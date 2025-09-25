import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/panen/printqr.dart';
import 'package:flutter_application_3/utils/bluetooth_helper.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_3/providers/panen/qr_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrintQrPage extends StatelessWidget {
  final String? noTrans;
  final String? blok;
  final String? rotasi;
  final String? nik;

  const PrintQrPage({
    super.key,
    this.noTrans,
    this.blok,
    this.rotasi,
    this.nik,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print QR'),
      ),
      body: PanenQrBody(
        noTrans: noTrans,
        blok: blok,
        rotasi: rotasi,
        nik: nik,
      ),
    );
  }
}

class PanenQrBody extends StatefulWidget {
  final String? noTrans;
  final String? blok;
  final String? rotasi;
  final String? nik;

  const PanenQrBody({
    super.key,
    this.noTrans,
    this.blok,
    this.rotasi,
    this.nik,
  });

  @override
  State<PanenQrBody> createState() => _PanenQrBodyState();
}

class _PanenQrBodyState extends State<PanenQrBody> {
  String? sesi = "1"; // Ganti sesuai kebutuhan
  String? tanggal = "-";
  String? waktu = "-";
  String? pemanen = "-";
  String? jjg = "-";
  String? brondolan = "-";

  ScreenshotController screenshotController = ScreenshotController();
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context
          .read<PanenQrProvider>()
          .loadPanenQr(widget.noTrans, widget.blok, widget.rotasi, widget.nik);

      // Optional: Setelah load, ambil data detail dari provider (atau dari db jika mau lebih dinamis)
      // Bisa ambil value dari provider atau dari hasil query yang sama
      final detail = context.read<PanenQrProvider>().lastDetailRow;

      print(detail);
      if (detail != null) {
        setState(() {
          sesi = widget.rotasi ?? "-";
          tanggal = detail['tanggal']?.toString().substring(0, 10) ?? "-";
          waktu = (detail['lastupdate'] != null &&
                  detail['lastupdate'].toString().length >= 19)
              ? detail['lastupdate'].toString().substring(11, 19)
              : "-";
          pemanen = detail['namakaryawan'] ?? "-";
          jjg = detail['jjgpanen']?.toString() ?? "-";
          brondolan = detail['brondolanpanen']?.toString() ?? "-";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrData = context.watch<PanenQrProvider>().qrData;
    final gradingList = context.watch<PanenQrProvider>().lastGradingRows;

    print(gradingList);
    return qrData == null
        ? const Center(child: Text('Data tidak ditemukan'))
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'DOCKET',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.blok ?? '-'} / ${sesi ?? '-'}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: qrData,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
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
                          await printQrAndInfo(
                              blok: widget.blok!,
                              qrData: qrData,
                              sesi: sesi.toString(),
                              tanggal: tanggal.toString(),
                              waktu: waktu.toString(),
                              pemanen: pemanen.toString(),
                              jjg: jjg.toString(),
                              brondolan: brondolan.toString(),
                              gradingList: gradingList,
                              notransaksi: widget.noTrans!);
                        }),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Sesi', sesi),
                        _infoRow('Tanggal', tanggal),
                        _infoRow('Waktu', waktu),
                        _infoRow('Pemanen', pemanen),
                        _infoRow('Jjg', jjg),
                        _infoRow('Brondolan', brondolan),
                        // ==== Tambahkan ini ====
                        if (gradingList.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(thickness: 1),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              'Denda/Grading',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          ...gradingList.map((g) => Row(
                                children: [
                                  Expanded(
                                      child: Text(g['deskripsi'] ?? '-',
                                          style:
                                              const TextStyle(fontSize: 15))),
                                  Text(g['jml'].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                ],
                              )),
                        ],
                        // ========================
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Text(value ?? '-',
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  void printFromOtherPage() async {
    final helper = BluetoothHelper();

    final savedAddress = await helper.getSavedPrinterAddress();
    if (savedAddress == null) {
      print("Belum ada printer disimpan");
      return;
    }

    final devices = await helper.getBondedDevices();
    final targetPrinter = devices.firstWhere(
      (d) => d.address == savedAddress,
      orElse: () => throw Exception("Printer tidak ditemukan"),
    );

    await helper.connectToPrinter(targetPrinter);
    await Future.delayed(const Duration(seconds: 1));

    helper.printSample(); // atau panggil fungsi print transaksi aslimu
  }
}
