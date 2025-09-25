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

class LihatHADetailPanen extends StatelessWidget {
  final String? notransaksi;
  final String? nik;
  final String? namakaryawan;
  const LihatHADetailPanen(
      {super.key, this.notransaksi, this.nik, this.namakaryawan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: LihatHADetailPanenBody(
          notransaksi: notransaksi, nik: nik, namakaryawan: namakaryawan),
    );
  }
}

class LihatHADetailPanenBody extends StatefulWidget {
  final String? notransaksi;
  final String? nik;
  final String? namakaryawan;
  const LihatHADetailPanenBody(
      {super.key, this.notransaksi, this.nik, this.namakaryawan});

  @override
  State<LihatHADetailPanenBody> createState() => _LihatHADetailPanenBodyState();
}

class _LihatHADetailPanenBodyState extends State<LihatHADetailPanenBody> {
  String _username = '';
  @override
  void initState() {
    super.initState();
    _loadUsername();

    final provider =
        Provider.of<HaPrestasiPanenProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.lihatHADetailPanen(
          notransaksi: widget.notransaksi, nik: widget.nik);
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
        String? namakaryawan = widget.namakaryawan;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Prestasi : $namakaryawan",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                CustomDataTableWidget(
                  data: context
                      .watch<HaPrestasiPanenProvider>()
                      .hapanenperkaryawanDetail,
                  columns: const [
                    'blok',
                    'namakaryawan',
                    'luaspanen',
                  ],
                  labelMapping: const {
                    'blok': 'Blok',
                    'namakaryawan': 'Nama Karyawan',
                    'luaspan en': 'Luas',
                  },
                  totalColumns: const ['luaspanen'],
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
