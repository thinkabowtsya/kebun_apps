import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/haprestasipanen/formHA.dart';
import 'package:flutter_application_3/pages/haprestasipanen/prestasipanen.dart';
import 'package:flutter_application_3/pages/panen/formpanen.dart';
import 'package:flutter_application_3/providers/cekRKH_provider.dart';
import 'package:flutter_application_3/providers/haprestasipanen/haprestasipanen_provider.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HaPrestasiPage extends StatelessWidget {
  const HaPrestasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HA Prestasi Panen'),
      ),
      body: const HaPrestasiBody(),
    );
  }
}

class HaPrestasiBody extends StatefulWidget {
  const HaPrestasiBody({super.key});

  @override
  State<HaPrestasiBody> createState() => _HaPrestasiBodyState();
}

class _HaPrestasiBodyState extends State<HaPrestasiBody> with RouteAware {
  DateTime selectedDate = DateTime.now();

  String username = '';

  // @override
  void initState() {
    super.initState();
    _loadUsername();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<HaPrestasiPanenProvider>(context, listen: false);
      String cleanDate = DateFormat('yyyy-MM-dd').format(selectedDate).trim();
      provider.fetchListHaPanen(cleanDate);
      provider.createTablePrestasiPanen();
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username')?.trim() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<HaPrestasiPanenProvider>(context, listen: false);
    // final bkmProvider = context.watch<HaPrestasiPanenProvider>();
    // final dataList = bkmProvider.bkmList;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final cekrkh =
                        Provider.of<CekRkhProvider>(context, listen: false);
                    final errors = await cekrkh.cekRKHA();

                    if (errors.isNotEmpty) {
                      // kalau ada error → tampilkan pesan
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Peringatan"),
                          content: Text(errors.join("\n")),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      await Navigator.pushNamed(context, '/add').then((value) {
                        setState(() {
                          String cleanDate = DateFormat('yyyy-MM-dd')
                              .format(selectedDate)
                              .trim();

                          context.read<HaPrestasiPanenProvider>();
                          provider.fetchListHaPanen(cleanDate);
                        });
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text('Transaksi Baru'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    // TODO: implement sinkronisasi
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text('Sinkronisasi'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });

                  provider.fetchListHaPanen(
                    DateFormat('yyyy-MM-dd').format(picked),
                  );
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: DateFormat('yyyy-MM-dd').format(selectedDate),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Text('masuk')
        // CustomDataTableWidget(
        //   data: provider.hapanen,
        //   columns: const [
        //     'tanggal',
        //     'namakaryawan',
        //     'notransaksi',
        //     'synchronized',
        //   ],
        //   labelMapping: const {
        //     'tanggal': 'Tanggal',
        //     'namakaryawan': 'Nama Karyawan',
        //     'notransaksi': 'No Transaksi',
        //     'synchronized': 'Sync',
        //   },
        //   enableBottomSheet: true,
        //   bottomSheetActions: [
        //     {
        //       'label': 'Synchronisasi',
        //       'colors': Colors.green,
        //       'icon': Icons.sync,
        //       'onTap': (row) => doSync(row),
        //     },
        //     {
        //       'label': 'Edit',
        //       'colors': Colors.blue,
        //       'icon': Icons.edit,
        //       'onTap': (row) => doEdit(row),
        //     },
        //     {
        //       'label': 'View',
        //       'colors': Colors.yellow,
        //       'icon': Icons.info,
        //       'onTap': (row) => doView(row),
        //     },
        //     {
        //       'label': 'Print',
        //       'colors': Colors.blue,
        //       'icon': Icons.print,
        //       'onTap': (row) => doPrint(row),
        //     },
        //     {
        //       'label': 'Hapus',
        //       'colors': Colors.red,
        //       'icon': Icons.delete,
        //       'onTap': (row) => doDelete(row, context),
        //     },
        //   ],
        // ),
        CustomDataTableWidget(
          data: provider.hapanen,
          columns: const [
            'tanggal',
            'namakaryawan',
            'notransaksi',
            'synchronized',
            // 'photo', // contoh kolom gambar
          ],
          rowHeight: 32,
          labelMapping: const {
            'tanggal': 'Tanggal',
            'namakaryawan': 'Nama Karyawan',
            'notransaksi': 'No Transaksi',
            'synchronized': 'Sync',
            // 'photo': 'Foto',
          },
          totalColumns: const [], // isi kalau perlu
          enableBottomSheet: true,
          bottomSheetActions: [
            {
              'label': 'Synchronisasi',
              'colors': Colors.green,
              'icon': Icons.sync,
              'onTap': (row) => doSync(row),
            },
            {
              'label': 'Edit',
              'colors': Colors.blue,
              'icon': Icons.edit,
              'onTap': (row) => doEdit(row),
            },
            {
              'label': 'View',
              'colors': Colors.yellow,
              'icon': Icons.info,
              'onTap': (row) => doView(row),
            },
            {
              'label': 'Print',
              'colors': Colors.blue,
              'icon': Icons.print,
              'onTap': (row) => doPrint(row),
            },
            {
              'label': 'Hapus',
              'colors': Colors.red,
              'icon': Icons.delete,
              'onTap': (row) => doDelete(row, context),
            },
          ],
          isRowSynced: (row) {
            final v = row['synchronized'];
            return (v is bool && v == true) ||
                (v is num && v != 0) ||
                (v is String && v.trim().isNotEmpty);
          },
          columnRenderers: {
            // === Kolom ikon sinkronisasi ===
            'synchronized': (row, ctx) {
              final val = row['synchronized'];
              final isSynced = (val is bool && val == true) ||
                  (val is num && val != 0) ||
                  (val is String && val.trim().isNotEmpty);

              if (isSynced) {
                return const DataCell(
                  Icon(Icons.check_circle, size: 20, color: Colors.green),
                );
              }

              // Belum sync → beri tombol aksi
              return DataCell(
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.red),
                  tooltip: 'Tandai sebagai synced',
                  onPressed: () {
                    // Callback custom milikmu
                    // markSync(row); // mis. ubah state + setState di luar
                  },
                ),
              );
            },

            // === Contoh kolom tombol custom (opsional) ===
            // 'aksi': (row, ctx) {
            //   return DataCell(
            //     Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         IconButton(
            //           icon: const Icon(Icons.visibility),
            //           onPressed: () => doView(row),
            //         ),
            //         IconButton(
            //           icon: const Icon(Icons.print),
            //           onPressed: () => doPrint(row),
            //         ),
            //       ],
            //     ),
            //   );
            // },
          },
        )
      ],
    );
  }

  void doEdit(row) {
    Navigator.of(context).pushNamed(
      '/edit',
      arguments: {
        'mode': FormHAMode.edit,
        'noTransaksi': row['notransaksi'],
      },
    ).then((value) {
      setState(() {
        print('send back');
      });
    });
  }

  void doView(row) {
    Navigator.of(context).pushNamed(
      '/liat-hapanen',
      arguments: {
        'noTransaksi': row['notransaksi'],
      },
    );
  }

  void doDelete(row, BuildContext context) async {
    // print(row);
    final panenProvider =
        Provider.of<HaPrestasiPanenProvider>(context, listen: false);
    // String cleanDate = DateFormat('yyyy-MM-dd').format(row['tanggal']).trim();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await panenProvider.deletePanen(
        row['notransaksi'].toString(),
      );

      setState(() {
        context
            .read<HaPrestasiPanenProvider>()
            .fetchListHaPanen(row['tanggal']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
        ),
      );
    }
  }

  void doSync(row) {
    Navigator.of(context).pushNamed('/sinkronisasi').then((value) {
      setState(() {
        context
            .read<HaPrestasiPanenProvider>()
            .fetchListHaPanen(row['tanggal']);
      });
    });
  }

  void doPrint(row) {}
}
