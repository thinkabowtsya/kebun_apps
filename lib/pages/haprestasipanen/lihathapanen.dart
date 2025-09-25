import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/haprestasipanen/haprestasipanen_provider.dart';
import 'package:flutter_application_3/providers/spb/spb_provider.dart';
import 'package:flutter_application_3/services/builderfoto.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LihatHAPanen extends StatelessWidget {
  final String? notransaksi;
  const LihatHAPanen({super.key, this.notransaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: LihatHAPanenBody(
        notransaksi: notransaksi,
      ),
    );
  }
}

class LihatHAPanenBody extends StatefulWidget {
  final String? notransaksi;
  const LihatHAPanenBody({super.key, this.notransaksi});

  @override
  State<LihatHAPanenBody> createState() => _LihatHAPanenBodyState();
}

class _LihatHAPanenBodyState extends State<LihatHAPanenBody> {
  String _username = '';
  @override
  void initState() {
    super.initState();
    _loadUsername();

    final provider =
        Provider.of<HaPrestasiPanenProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.lihatHAPanen(notransaksi: widget.notransaksi);
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
    final notrans = widget.notransaksi;

    return Consumer<HaPrestasiPanenProvider>(
      builder: (context, provider, _) {
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
                  data: context.watch<HaPrestasiPanenProvider>().hapanenHeader,
                  columns: const [
                    'tanggal',
                    'mandor',
                  ],
                  labelMapping: const {
                    'tanggal': 'Tanggal',
                    'mandor': 'Mandor',
                  },

                  // totalColumns: ['jumlah', 'bonus'],
                  enableBottomSheet: false,
                ),
                const SizedBox(height: 8),
                CustomDataTableWidget(
                  data: context.watch<HaPrestasiPanenProvider>().hapanenperblok,
                  columns: const [
                    'blok',
                    'luasareaproduktif',
                    'luaspanen',
                  ],
                  labelMapping: const {
                    'blok': 'Blok',
                    'luasareaproduktif': 'Luas Blok',
                    'luaspanen': 'Luas Panen',
                  },
                  totalColumns: const ['luaspanen', 'luasareaproduktif'],
                  enableBottomSheet: false,
                ),
                const SizedBox(height: 8),
                CustomDataTableWidget(
                    data: context
                        .watch<HaPrestasiPanenProvider>()
                        .hapanenperkaryawan,
                    columns: const [
                      'namakaryawan',
                      'luaspanen',
                    ],
                    labelMapping: const {
                      'namakaryawan': 'Nama Karyawan',
                      'luaspanen': 'Luas Panen',
                    },
                    totalColumns: const [
                      'luaspanen',
                    ],
                    enableBottomSheet: true,
                    bottomSheetActions: [
                      {
                        'label': 'View',
                        'colors': Colors.yellow,
                        'icon': Icons.info,
                        'onTap': (row) => doView(row),
                      },
                    ]),
              ],
            ),
          ),
        );
      },
    );
  }

  void doView(row) {
    Navigator.of(context).pushNamed(
      '/view-detailhapanen',
      arguments: {
        'noTransaksi': row['notransaksi'],
        'nik': row['nik'],
        'namakaryawan': row['namakaryawan']
      },
    );
  }
}
