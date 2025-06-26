// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/kehadiran_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
// import 'package:flutter_application_3/services/FormMode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormAbsensiPage extends StatelessWidget {
  const FormAbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Baru'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: const FormAbsensiBody(),
    );
  }
}

class FormAbsensiBody extends StatefulWidget {
  const FormAbsensiBody({super.key});

  @override
  State<FormAbsensiBody> createState() => _FormAbsensiBodyState();
}

class _FormAbsensiBodyState extends State<FormAbsensiBody> {
  int _selectedPresenceOption = 2;
  String _username = '';
  String? selectedKaryawan;
  final TextEditingController _absensiController = TextEditingController();
  final TextEditingController _hkController = TextEditingController();
  final TextEditingController _premiController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  bool _isHasilKerjaValid = false;

  @override
  void dispose() {
    _absensiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  Widget build(BuildContext context) {
    final data = context.watch<AbsensiProvider>().absensiList;
    return Consumer3<AbsensiProvider, KehadiranProvider, BkmProvider>(
        builder: (context, provider, kehadiranProvider, bkmProvider, _) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kehadiran",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: [
                  RadioListTile(
                    value: 1,
                    groupValue: _selectedPresenceOption,
                    title: const Text("Seluruhnya"),
                    onChanged: (value) {
                      kehadiranProvider.loadKaryawan(value);
                      setState(() {
                        _selectedPresenceOption = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    value: 2,
                    groupValue: _selectedPresenceOption,
                    title: Text(
                        "Hanya Kemandoran (${_username.isNotEmpty ? _username.toUpperCase() : '...'})"),
                    onChanged: (value) {
                      setState(() {
                        kehadiranProvider.loadKaryawan(value);

                        _selectedPresenceOption = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    value: 3,
                    groupValue: _selectedPresenceOption,
                    title: const Text("Scan Jari"),
                    onChanged: (value) {
                      setState(() {
                        _selectedPresenceOption = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Karyawan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedKaryawan,
                  // value: selectedKaryawan,
                  items: _buildKaryawanItems(kehadiranProvider.karyawan),
                  onChanged: (value) {
                    setState(() {
                      selectedKaryawan = value;
                    });
                  },
                  hint: const Text("Pilih Karyawan"),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Hadir",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _absensiController,
                textAlign: TextAlign.start,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
                focusNode: FocusNode(canRequestFocus: false),
              ),
              const SizedBox(height: 10),
              const Text(
                "HK",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hkController,
                textAlign: TextAlign.start,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
                focusNode: FocusNode(canRequestFocus: false),
              ),
              const SizedBox(height: 10),
              const Text(
                "Premi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _premiController,
                textAlign: TextAlign.start,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
                focusNode: FocusNode(canRequestFocus: false),
              ),
              const Text(
                "Keterangan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                textAlign: TextAlign.start,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
                focusNode: FocusNode(canRequestFocus: false),
              ),
              const SizedBox(height: 8),
              ActionButton(
                label: 'SIMPAN',
                onPressed: () async {
                  final notrans = bkmProvider.notransaksi;
                  print('simpan $notrans');
                },
              ),
              _buildDetailSection(context, provider, data),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailSection(
      BuildContext context, AbsensiProvider absensiProvider, datas) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        border: TableBorder.all(color: Colors.grey),
        headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
        headingTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dataRowHeight: 32,
        headingRowHeight: 40,
        columns: const [
          DataColumn(label: Text('Nama Karyawan')),
          DataColumn(label: Text('Kode Absen')),
          DataColumn(label: Text('HK')),
          DataColumn(label: Text('Premi')),
          DataColumn(label: Text('Keterangan')),
        ],
        rows: [
          ...datas.map((item) {
            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.info),
                              title: const Text('Detail'),
                              onTap: () async {},
                            ),
                            ListTile(
                              leading:
                                  const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Hapus'),
                              onTap: () async {
                                Navigator.pop(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: const Text(
                                        'Yakin ingin menghapus data ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Data berhasil dihapus'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              cells: [
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('')),
              ],
            );
          }).toList(),
          // DataRow(
          //   color: WidgetStateProperty.all(Colors.grey[300]),
          //   cells: [
          //     const DataCell(
          //       Text(
          //         'TOTAL',
          //         style: TextStyle(fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //     const DataCell(Text('-')),
          //     DataCell(
          //       Text(
          //         absensiProvider.absensiList
          //             .fold<num>(
          //               0,
          //               (sum, item) => sum + (item['jhk'] ?? 0),
          //             )
          //             .toString(),
          //         style: const TextStyle(fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //     DataCell(
          //       Text(
          //         absensiProvider.absensiList
          //             .fold<num>(
          //               0,
          //               (sum, item) => sum + (item['hasilkerja'] ?? 0),
          //             )
          //             .toString(),
          //         style: const TextStyle(fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildKaryawanItems(
      List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DropdownMenuItem(
        value: item['nik'].toString(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['namakaryawan']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${item['subbagian']} | ${item['nik']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
