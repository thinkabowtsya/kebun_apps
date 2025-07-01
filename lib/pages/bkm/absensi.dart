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
  bool premiDisabled = true;

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

    // Gabungkan semua async flow
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUsername(); // Tunggu username selesai dimuat

      final provider = Provider.of<AbsensiProvider>(context, listen: false);
      final bkmProvider = Provider.of<BkmProvider>(context, listen: false);

      final notrans = bkmProvider.notransaksi;

      await provider.fetchAbsensiDetail(notrans: notrans, username: _username);

      if (mounted) {
        setState(() {
          provider.selectNoAkunDefault();
          premiDisabled = false;
        });
      }
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username')?.trim() ?? '';
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
                        kehadiranProvider.loadKaryawan(1);
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
                  // RadioListTile(
                  //   value: 3,
                  //   groupValue: _selectedPresenceOption,
                  //   title: const Text("Scan Jari"),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedPresenceOption = value!;
                  //     });
                  //   },
                  // ),
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
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
                  value: provider.selectedAbsensiValue,
                  items: _buildAbsensiItems(provider.absensi),
                  onChanged: (value) {
                    setState(() {
                      premiDisabled = value != 'H';
                    });

                    provider.setSelectedAbsensiValue(value.toString());
                  },
                  hint: const Text("Pilih Absensi"),
                  isDense: false,
                  elevation: 1,
                ),
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
                keyboardType: TextInputType.number,
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
                enabled: !premiDisabled,
                keyboardType: TextInputType.number,
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

                  _submit(provider: provider);
                },
              ),
              _buildDetailSection(
                  context, provider, data, bkmProvider.notransaksi),
            ],
          ),
        ),
      );
    });
  }

  Future<bool> _submit({required AbsensiProvider provider}) async {
    final bkmProvider = Provider.of<BkmProvider>(context, listen: false);
    String? absensi = provider.selectedAbsensiValue;
    String? karyawan = selectedKaryawan;
    int hk = int.parse(_hkController.text);
    String keterangan = _keteranganController.text;
    String insentif = _premiController.text;
    String? asisten = bkmProvider.selectedAsistenValue;
    String? mandor1 = bkmProvider.selectedMandor1Value;
    String? mandor = bkmProvider.selectedMandorValue;
    String kodekegiatan = 'ABSENSI';
    String? notransaksi = bkmProvider.notransaksi;

    final errors = <String>[];

    if (karyawan == '') {
      errors.add('Silahkan pilih karyawan');
    } else if (karyawan == asisten ||
        karyawan == mandor ||
        karyawan == mandor1) {
      errors.add('Karyawan sudah dipakai di header transaksi');
    } else if (absensi == '') {
      errors.add('Silahkan pilih kode presensi');
    } else if (hk <= 0) {
      // if (hk <= 0) {
      errors.add('HK tidak boleh 0/Kosong');
      // }
    } else if (hk == 0) {
      hk = 0;
    } else {
      provider.simpanAbsensi(
          absensi: absensi,
          karyawan: karyawan,
          keterangan: keterangan,
          hk: hk,
          insentif: insentif,
          asisten: asisten,
          mandor1: mandor1,
          mandor: mandor,
          kodekegiatan: kodekegiatan,
          notransaksi: notransaksi);
    }

    if (errors.isNotEmpty) {
      await showDialog(
        context: context,
        useRootNavigator:
            false, // ini penting karena kamu pakai custom Navigator
        builder: (_) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: Text(errors.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );

      return false;
    }

    return true;
  }

  Widget _buildDetailSection(BuildContext context,
      AbsensiProvider absensiProvider, datas, notransaksi) {
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
                              leading:
                                  const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Hapus'),
                              onTap: () async {
                                Navigator.pop(
                                    context); // Tutup bottom sheet dulu

                                // Tunggu sebentar biar konteks stabil
                                await Future.delayed(
                                    const Duration(milliseconds: 200));

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
                                  if (notransaksi != null &&
                                      notransaksi.isNotEmpty) {
                                    await absensiProvider.deleteAbsensi(
                                        notransaksi: notransaksi,
                                        nik: item['nik']);

                                    // Gunakan mounted context aman untuk snackbar
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Data berhasil dihapus')),
                                      );
                                    }
                                    // setState(() {
                                    //   absensiProvider.setShouldRefresh(true);
                                    // });
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Transaksi tidak valid')),
                                      );
                                    }
                                  }
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
                DataCell(Text(item['namakaryawan'].toString())),
                DataCell(Text(item['absensi'].toString())),
                DataCell(Text(item['jhk'].toString())),
                DataCell(Text(item['insentif'].toString())),
                DataCell(Text(item['jam_overtime'].toString())),
              ],
            );
          }).toList(),
          DataRow(
            color: WidgetStateProperty.all(Colors.grey[300]),
            cells: [
              const DataCell(
                Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataCell(Text('-')),
              DataCell(
                Text(
                  absensiProvider.absensiList
                      .fold<num>(
                        0,
                        (sum, item) => sum + (item['jhk'] ?? 0),
                      )
                      .toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataCell(Text('-')),
              const DataCell(Text('-')),
            ],
          ),
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

  List<DropdownMenuItem<String>> _buildAbsensiItems(
      List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DropdownMenuItem(
        value: item['key'].toString(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['val']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
