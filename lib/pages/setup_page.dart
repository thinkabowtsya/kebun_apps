import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/basis_norma_page.dart';
import 'package:flutter_application_3/pages/blok_page.dart';
import 'package:flutter_application_3/pages/karyawan_page.dart';
import 'package:flutter_application_3/pages/kegiatan_page.dart';
import 'package:flutter_application_3/pages/kendaraan_page.dart';
import 'package:flutter_application_3/pages/sinkron_page.dart';


// ignore: use_key_in_widget_constructors
class SetupPage extends StatelessWidget {
  // List data menu
  final List<Map<String, dynamic>> menuItems = [
    {
      "title": "Informasi Masuk Aplikasi",
      "isHeader": false,
      "page": "informasi"
    },
    {"title": "Ubah Sandi", "isHeader": false, "page": "ubahsandi"},
    {"title": "Sinkronisasi", "isHeader": false, "page": "sinkron"},
    {"title": "Printer Bluetooth", "isHeader": false, "page": "printer"},
    {"title": "Finger Setting", "isHeader": false, "page": "finger"},
    {"title": "Ganti Bahasa", "isHeader": false, "page": "gantibahasa"},
  ];

  void navigateToPage(BuildContext context, String page) {
    if (page == "ubahsandi") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KaryawanPage(),
        ),
      );
    } else if (page == 'sinkron') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SinkronPage(),
        ),
      );
    } else if (page == 'printer') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BlokPage(),
        ),
      );
    } else if (page == 'finger') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KegiatanPage(),
        ),
      );
    } else if (page == 'gantibahasa') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KendaraanPage(),
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
        title: const Text('Pengaturan'),
        backgroundColor: Colors.white,
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
