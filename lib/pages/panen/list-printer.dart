import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/printqr.dart';
import 'package:flutter_application_3/utils/bluetooth_helper.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_application_3/providers/panen/qr_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ListPrinterPage extends StatelessWidget {
  final String? noTrans;
  final String? blok;
  final String? rotasi;
  final String? nik;

  const ListPrinterPage({
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
      await context.read<PanenProvider>().fetchListPrinter(widget.noTrans);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final listPrinter = context.watch<PanenProvider>().listPrinter;

    return Consumer<PanenProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDataTableWidget(
                  data: context.watch<PanenProvider>().listPrinter,
                  columns: const [
                    'blok',
                    'rotasi',
                    'namakaryawan',
                    'jjgpanen',
                    'luaspanen',
                    'brondolanpanen',
                    'cetakan',
                  ],
                  labelMapping: const {
                    'blok': 'TPH',
                    'rotasi': 'Sesi',
                    'namakaryawan': 'Nama Karyawan',
                    'jjgpanen': 'Jjg',
                    'luaspanen': 'Luas',
                    'brondolanpanen': 'Brondolan',
                    'cetakan': 'Cetakan',
                  },
                  enableBottomSheet: true,
                  bottomSheetActions: [
                    {
                      'label': 'Print',
                      'icon': Icons.print,
                      'colors': Colors.green,
                      'onTap': (row) => doPrint(row),
                    },
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void doPrint(row) async {
    await Navigator.of(context).pushNamed(
      '/print-qr',
      arguments: {
        'noTransaksi': row['notransaksi'].toString(),
        'blok': row['blok'].toString(),
        'rotasi': row['rotasi'].toString(),
        'nik': row['nik'].toString(),
      },
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
