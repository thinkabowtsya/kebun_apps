import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LihatPanen extends StatelessWidget {
  final String? notransaksi;
  const LihatPanen({super.key, this.notransaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: LihatPanenBody(
        notransaksi: notransaksi,
      ),
    );
  }
}

class LihatPanenBody extends StatefulWidget {
  final String? notransaksi;
  const LihatPanenBody({super.key, this.notransaksi});

  @override
  State<LihatPanenBody> createState() => _LihatPanenBodyState();
}

class _LihatPanenBodyState extends State<LihatPanenBody> {
  String _username = '';
  @override
  void initState() {
    super.initState();
    _loadUsername();

    final provider = Provider.of<PanenProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.lihatPanen(notransaksi: widget.notransaksi);
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username')?.trim() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // final data = context.watch<PanenProvider>().bkmListing;
    final notrans = widget.notransaksi;

    return Consumer2<PanenProvider, PrestasiProvider>(
      builder: (context, provider, absensiProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "No Sinkronisasi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                const TextField(
                  enabled: false,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Transaksi : $notrans",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                CustomDataTableWidget(
                  data: context.watch<PanenProvider>().panenHeader,
                  columns: const [
                    'tanggal',
                    'mandor1',
                    'mandor',
                    'kerani',
                  ],
                  labelMapping: const {
                    'tanggal': 'Tanggal',
                    'mandor1': 'Mandor 1',
                    'kerani': 'Kerani',
                  },

                  // totalColumns: ['jumlah', 'bonus'],
                  enableBottomSheet: false,
                ),
                const SizedBox(height: 8),
                CustomDataTableWidget(
                  data: context.watch<PanenProvider>().panenperblok,
                  columns: const [
                    'blok',
                    'jjgpanen',
                    'brondolanpanen',
                  ],
                  labelMapping: const {
                    'blok': 'Blok',
                    'jjgpanen': 'Jjg',
                    'brondolanpanen': 'Brondolan',
                  },
                  totalColumns: ['jjgpanen', 'brondolanpanen'],
                  enableBottomSheet: false,
                ),
                const SizedBox(height: 8),
                CustomDataTableWidget(
                    data: context.watch<PanenProvider>().panenperkaryawan,
                    columns: const [
                      'namakaryawan',
                      'jjgpanen',
                      'brondolanpanen',
                    ],
                    labelMapping: const {
                      'namakaryawan': 'Nama Karyawan',
                      'jjgpanen': 'Jjg',
                      'brondolanpanen': 'Brondolan',
                    },
                    totalColumns: ['jjgpanen', 'brondolanpanen'],
                    enableBottomSheet: true,
                    bottomSheetActions: [
                      {
                        'label': 'View',
                        'colors': Colors.yellow,
                        'icon': Icons.info,
                        'onTap': (row) => doView(row),
                      },
                    ]),
                const Text(
                  "Presensi Kehadiran Umum:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                CustomDataTableWidget(
                  data: context.watch<PanenProvider>().panenPresensi,
                  columns: const [
                    'namakaryawan',
                    'jhk',
                    'insentif',
                    'jam_overtime',
                  ],
                  labelMapping: const {
                    'namakaryawan': 'Nama Karyawan',
                    'jhk': 'HK',
                    'premi': 'Premi',
                    'jam_overtime': 'Keterangan',
                  },
                  totalColumns: ['jhk', 'premi'],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void doView(row) {
    print(row);
    Navigator.of(context).pushNamed(
      '/view-detailpanen',
      arguments: {
        'noTransaksi': row['notransaksi'],
        'nik': row['nik'],
        'namakaryawan': row['namakaryawan']
      },
    );
  }
}
