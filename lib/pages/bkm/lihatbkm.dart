import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
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
    print(data);
    return Consumer2<BkmProvider, AbsensiProvider>(
      builder: (context, provider, absensiProvider, _) {
        if (provider.isLoadingMandor ||
            provider.isLoadingMandor1 ||
            provider.isLoadingAsisten) {
          return const Center(
            child: CircularProgressIndicator(),
          );
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
              ],
            ),
          ),
        );
      },
    );
  }
}
