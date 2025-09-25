import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/panen/formpanen.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/cekRKH_provider.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_3/pages/bkm/addData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanenPage extends StatelessWidget {
  const PanenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kegiatan Panen'),
      ),
      body: const PanenBody(),
    );
  }
}

class PanenBody extends StatefulWidget {
  const PanenBody({super.key});

  @override
  State<PanenBody> createState() => _PanenBodyState();
}

class _PanenBodyState extends State<PanenBody> with RouteAware {
  DateTime selectedDate = DateTime.now();

  String username = '';

  // @override
  void initState() {
    super.initState();
    _loadUsername();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<PanenProvider>(context, listen: false);
      String cleanDate = DateFormat('yyyy-MM-dd').format(selectedDate).trim();
      provider.fetchListPanen(cleanDate);
      provider.createTablePanen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // print(selectedDate.toString());

    final provider = Provider.of<PanenProvider>(context, listen: false);
    String cleanDate = DateFormat('yyyy-MM-dd').format(selectedDate).trim();
    if (provider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PanenProvider>();
        provider.fetchListPanen(cleanDate);

        provider.setShouldRefresh(false);
      });
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username')?.trim() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PanenProvider>(context, listen: false);
    final bkmProvider = context.watch<PanenProvider>();
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
                      Navigator.pushNamed(context, '/add').then((value) {
                        setState(() {
                          String cleanDate = DateFormat('yyyy-MM-dd')
                              .format(selectedDate)
                              .trim();

                          context.read<PanenProvider>();
                          provider.fetchListPanen(cleanDate);
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
                  onPressed: () {},
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

                  provider.fetchListPanen(
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
        CustomDataTableWidget(
          data: provider.listpanen,
          columns: const [
            'tanggal',
            'namakaryawan',
            'notransaksi',
            'synchronized',
          ],
          rowHeight: 32,
          labelMapping: const {
            'tanggal': 'Tanggal',
            'namakaryawan': 'Nama Karyawan',
            'notransaksi': 'No Transaksi',
            'synchronized': 'Sync',
          },
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
          // isRowSynced: (row) {
          //   final v = row['synchronized'];
          //   return (v is bool && v == true) ||
          //       (v is num && v != 0) ||
          //       (v is String && v.trim().isNotEmpty);
          // },
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
          },
        ),
      ],
    );
  }

  void doEdit(row) {
    Navigator.of(context).pushNamed(
      '/edit',
      arguments: {
        'mode': FormPanenMode.edit,
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
      '/lihat-panen',
      arguments: {
        'noTransaksi': row['notransaksi'],
      },
    );
  }

  void doDelete(row, BuildContext context) async {
    print(row);
    final panenProvider = Provider.of<PanenProvider>(context, listen: false);
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

      context.read<PanenProvider>().fetchListPanen(row['tanggal']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
        ),
      );
    }
  }

  void doSync(row) {
    Navigator.of(context).pushNamed('/sinkronisasi');
  }

  void doPrint(row) async {
    await Navigator.of(context).pushNamed(
      '/list-printer',
      arguments: {
        'noTransaksi': row['notransaksi'].toString(),
      },
    );
  }
}
