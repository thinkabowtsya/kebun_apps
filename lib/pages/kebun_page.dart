import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/bkm_module.dart';
import 'package:flutter_application_3/pages/bkm_page.dart';
import 'package:flutter_application_3/pages/haprestasipanen/hapanen_module.dart';
import 'package:flutter_application_3/pages/laporanrkh/laporanrkh_module.dart';
import 'package:flutter_application_3/pages/laporanrkh/laporanrkh_page.dart';
import 'package:flutter_application_3/pages/panen/panen_module.dart';
import 'package:flutter_application_3/pages/spb/spb_module.dart';

class KebunPage extends StatelessWidget {
  // List data menu
  final List<Map<String, dynamic>> menuItems = [
    {"title": "Transaksi", "isHeader": true, "page": "transaksi"},
    {"title": "Buku Kerja Mandor", "isHeader": false, "page": "bkm"},
    {"title": "Buku Panen", "isHeader": false, "page": "buku_panen"},
    // {"title": "Verifikasi", "isHeader": false, "page": "verifikasi"},
    {"title": "Surat Pengantar Buah", "isHeader": false, "page": "spb"},
    // {"title": "BBC", "isHeader": false, "page": "bbc"},
    // {"title": "Taksasi Panen", "isHeader": false, "page": "taksasi_panen"},
    {"title": "HA Prestasi Panen", "isHeader": false, "page": "happ"},
    {"title": "Laporan", "isHeader": true, "page": "laporan"},
    {"title": "Laporan RKH", "isHeader": false, "page": "rkh"},
  ];

  KebunPage({super.key});

  void navigateToPage(BuildContext context, String page) {
    if (page == "bkm") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BkmModule(), // TANPA child
        ),
      );
    } else if (page == "buku_panen") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PanenModule(), // TANPA child
        ),
      );
    } else if (page == "happ") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const HaPrestasiPanenModule(), // TANPA child
        ),
      );
    } else if (page == "spb") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SpbModule(),
        ),
      );
    } else if (page == "rkh") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LaporanRKHModule(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Klik $page")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebun'),
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];

          if (item["isHeader"]) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                item["title"],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => navigateToPage(context, item['page']),
                child: Text(
                  item["title"],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
