import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/services/builderfoto.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LihatBkm extends StatelessWidget {
  final String? notransaksi;
  const LihatBkm({super.key, this.notransaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: LihatBkmBody(
        notransaksi: notransaksi,
      ),
    );
  }
}

class LihatBkmBody extends StatefulWidget {
  final String? notransaksi;
  const LihatBkmBody({super.key, this.notransaksi});

  @override
  State<LihatBkmBody> createState() => _LihatBkmBodyState();
}

class _LihatBkmBodyState extends State<LihatBkmBody> {
  String _username = '';
  @override
  void initState() {
    super.initState();
    _loadUsername();

    final provider = Provider.of<BkmProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.lihatBkm(notransaksi: widget.notransaksi);
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
    final data = context.watch<BkmProvider>().bkmListing;
    final notrans = widget.notransaksi;
    // final prestasi = context.watch<BkmProvider>().prestasiListing;
    // final namakegiatan = prestasi.first['namakegiatan'];

    return Consumer2<BkmProvider, AbsensiProvider>(
      builder: (context, provider, absensiProvider, _) {
        if (provider.isLoadingKegiatan) {
          return const Center(child: CircularProgressIndicator());
        }

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
                  data: context.watch<BkmProvider>().bkmListing,
                  columns: const ['tanggal', 'mandor', 'mandor1', 'asisten'],
                  labelMapping: const {
                    'tanggal': 'Tanggal',
                    'mandor': 'Mandor',
                    'mandor1': 'Mandor1',
                  },
                  // totalColumns: ['jumlah', 'bonus'],
                  enableBottomSheet: false,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Presensi Kehadiran Umum : ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                CustomDataTableWidget(
                  data: context.watch<BkmProvider>().kehadiranUmumListing,
                  columns: const [
                    'namakaryawan',
                    'jhk',
                    'insentif',
                    'jam_overtime'
                  ],
                  labelMapping: const {
                    'namakaryawan': 'Nama Karyawan',
                    'jhk': 'HK',
                    'insentif': 'Insentif',
                    'jam_overtime': 'Keterangan',
                  },
                  totalColumns: const ['jumlah', 'jhk'],
                  enableBottomSheet: false,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.namakegiatan!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                CustomDataTableWidget(
                  data: context.watch<BkmProvider>().prestasiListing,
                  columns: const [
                    'kodeorg',
                    'jhk',
                    'hasilkerja',
                    'insentif',
                    'premilebihbasis',
                    'extrafooding',
                    'nobkm',
                    'fotoStart2',
                    'jumlahhasilkerja',
                    'fotoEnd2',
                  ],
                  labelMapping: const {
                    'kodeorg': 'Blok',
                    'jhk': 'HK',
                    'hasilkerja': 'Hasil Kerja',
                    'insentif': 'Premi',
                    'premilebihbasis': 'Premi Lebih Basis',
                    'extrafooding': 'Extra Fooding',
                    'nobkm': 'Foto Awal',
                    'fotoStart2': 'Foto Awal 2',
                    'jumlahhasilkerja': 'Foto Akhir',
                    'fotoEnd2': 'Foto Akhir 2',
                  },
                  totalColumns: const ['jhk', 'hasilkerja'],
                  enableBottomSheet: false,
                  rowHeight: 60,

                  // Render kolom foto sebagai image dari Base64
                  columnRenderers: {
                    'fotoStart2': buildPhotoCellAny('fotoStart2', size: 72),
                    'nobkm': buildPhotoCellAny('nobkm', size: 72),
                    'jumlahhasilkerja':
                        buildPhotoCellAny('jumlahhasilkerja', size: 72),
                    // 'fotoEnd2': buildPhotoCellAny('fotoEnd2', size: 72),
                    'fotoEnd2': buildPhotoCellAny('fotoEnd2', size: 72),
                  },
                ),
                const Text(
                  'Kehadiran :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                CustomDataTableWidget(
                  data: context.watch<BkmProvider>().prestasiListing,
                  columns: const [
                    'namakaryawan',
                    'jhk',
                    'hasilkerja',
                    'insentif',
                    'premilebihbasis',
                    'extrafooding'
                  ],
                  labelMapping: const {
                    'namakaryawan': 'Nama Karyawan',
                    'jhk': 'HK',
                    'hasilkerja': 'Hasil Kerja',
                    'insentif': 'Premi',
                    'premilebihbasis': 'Premi Lebih Basis',
                    'extrafooding': 'Extra Fooding',
                  },
                  totalColumns: const ['jhk', 'hasilkerja'],
                  enableBottomSheet: false,
                ),
                const Text(
                  'Material :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                CustomDataTableWidget(
                  data: context.watch<BkmProvider>().materialListing,
                  columns: const [
                    'namabarang',
                    'satuan',
                    'kwantitas',
                  ],
                  labelMapping: const {
                    'namabarang': 'Nama Barang',
                    'satuan': 'Satuan',
                    'kwantitas': 'Kuantitas',
                  },
                  totalColumns: const ['kwantitas'],
                  enableBottomSheet: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
