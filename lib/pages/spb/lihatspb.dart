import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/spb/spb_provider.dart';
import 'package:flutter_application_3/services/builderfoto.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LihatSpb extends StatelessWidget {
  final String? notransaksi;
  const LihatSpb({super.key, this.notransaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: LihatSpbBody(
        notransaksi: notransaksi,
      ),
    );
  }
}

class LihatSpbBody extends StatefulWidget {
  final String? notransaksi;
  const LihatSpbBody({super.key, this.notransaksi});

  @override
  State<LihatSpbBody> createState() => _LihatSpbBodyState();
}

class _LihatSpbBodyState extends State<LihatSpbBody> {
  String _username = '';
  @override
  void initState() {
    super.initState();
    _loadUsername();

    final provider = Provider.of<SpbProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.lihatSpb(notransaksi: widget.notransaksi);
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

    return Consumer<SpbProvider>(
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
                  data: context.watch<SpbProvider>().spbHeader,
                  columns: const [
                    'tanggal',
                    'afdeling',
                    'penerimatbs',
                    'driver',
                    'nopol',
                    'synchronized'
                  ],
                  labelMapping: const {
                    'tanggal': 'Tanggal',
                    'afdeling': 'Afdeling',
                    'penerimatbs': 'Pabrik',
                    'driver': 'No Polisi',
                    'synchronized': 'Status',
                    'spbfile': 'foto',
                  },
                  columnRenderers: {
                    'spbfile': buildPhotoCellAny('spbfile', size: 40),
                  },
                  // totalColumns: ['jumlah', 'bonus'],
                  enableBottomSheet: false,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Transaksi Detail : ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                CustomDataTableWidget(
                  data: context.watch<SpbProvider>().spbDetailList,
                  columns: const [
                    'blok',
                    'nik',
                    'rotasi',
                    'blok'
                        'jjg'
                        'brondolan'
                  ],
                  labelMapping: const {
                    'blok': 'TPH/noSpb',
                    'nik': 'nik',
                    'rotasi': 'Rotasi',
                    'status': 'Status',
                    'jjg': 'Jjg',
                    'brondolan': 'Brondolan',
                  },
                  totalColumns: const ['jjg', 'brondolan'],
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
