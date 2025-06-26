import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/basis_norma_page.dart';
import 'package:flutter_application_3/pages/blok_page.dart';
import 'package:flutter_application_3/pages/hama_page.dart';
import 'package:flutter_application_3/pages/karyawan_page.dart';
import 'package:flutter_application_3/pages/kegiatan_page.dart';
import 'package:flutter_application_3/pages/kemandoran_page.dart';
import 'package:flutter_application_3/pages/kendaraan_page.dart';
import 'package:flutter_application_3/pages/kode_denda_page.dart';
import 'package:flutter_application_3/pages/mutu_ancak_page.dart';
import 'package:flutter_application_3/pages/tph_page.dart';

// ignore: use_key_in_widget_constructors
class MasterPage extends StatelessWidget {
  // List data menu
  final List<Map<String, dynamic>> menuItems = [
    {"title": "Laporan", "isHeader": true, "page": "laporan"},
    {"title": "Karyawan", "isHeader": false, "page": "karyawan"},
    {"title": "Basis Norma Kegiatan", "isHeader": false, "page": "bnk"},
    {"title": "Blok", "isHeader": false, "page": "blok"},
    {"title": "Kegiatan", "isHeader": false, "page": "kegiatan"},
    {"title": "Kendaraan", "isHeader": false, "page": "kendaraan"},
    {"title": "Kode Denda", "isHeader": false, "page": "kode_denda"},
    {"title": "Mutu Ancak", "isHeader": false, "page": "mutu_ancak"},
    {"title": "Hama", "isHeader": false, "page": "hama"},
    {"title": "TPH", "isHeader": false, "page": "tph"},
    {"title": "Kemandoran", "isHeader": false, "page": "kemandoran"},
  ];

  void navigateToPage(BuildContext context, String page) {
    if (page == "karyawan") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KaryawanPage(),
        ),
      );
    } else if (page == 'bnk') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BasisNormaKegiatanPage(),
        ),
      );
    } else if (page == 'blok') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BlokPage(),
        ),
      );
    } else if (page == 'kegiatan') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KegiatanPage(),
        ),
      );
    } else if (page == 'kendaraan') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KendaraanPage(),
        ),
      );
    } else if (page == 'kode_denda') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KodedendaPage(),
        ),
      );
    } else if (page == 'mutu_ancak') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MutuAncakPage(),
        ),
      );
    } else if (page == 'hama') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HamaPage(),
        ),
      );
    } else if (page == 'tph') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TphPage(),
        ),
      );
    } else if (page == 'kemandoran') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const KemandoranPage(),
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
        title: const Text('Master Data'),
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
