import 'package:flutter/material.dart';

class TransaksiProvider with ChangeNotifier {
  final List<Map<String, String>> _transaksiData = [
    {
      'Tanggal': '2025-05-13',
      'Nama': 'SULIANA',
      'No Transaksi': '20250513145249-556',
      'Sinkron': 'Belum',
    },
  ];

  List<Map<String, String>> get transaksiData => _transaksiData;

  // Menambahkan data transaksi baru
  void addData(String nama, DateTime selectedDate) {

    _transaksiData.add({
      'Tanggal': '${selectedDate.toLocal()}'.split(' ')[0],
      'Nama': nama,
      'No Transaksi': '20250513145249-557',
      'Sinkron': 'Belum',
    });
    notifyListeners(); 
  }

  void sinkronisasi() {
    for (var item in _transaksiData) {
      item['Sinkron'] = 'Sudah';
    }
    notifyListeners(); 
  }
}
