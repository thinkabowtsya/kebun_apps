import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/panen/prestasipanen.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/panen/detail_provider.dart';
import 'package:flutter_application_3/providers/panen/mutubuah_provider.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MutuBuahPanenMode {
  add,
  edit,
}

class MutuBuahPanenPage extends StatelessWidget {
  final MutuBuahPanenMode mode;
  final String? initialNoTransaksi;
  final String? blok;

  const MutuBuahPanenPage({
    super.key,
    this.mode = MutuBuahPanenMode.add,
    this.initialNoTransaksi,
    this.blok,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            mode == MutuBuahPanenMode.add ? 'Mutu Ancak' : 'Edit Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: MutuBuahPanenBody(
        mode: mode,
        initialNoTransaksi: initialNoTransaksi,
        blok: blok,
      ),
    );
  }
}

class MutuBuahPanenBody extends StatefulWidget {
  final MutuBuahPanenMode mode;
  final String? initialNoTransaksi;
  final String? blok;

  const MutuBuahPanenBody({
    super.key,
    this.mode = MutuBuahPanenMode.add,
    this.initialNoTransaksi,
    this.blok,
  });

  @override
  State<MutuBuahPanenBody> createState() => _MutuBuahPanenBodyState();
}

class _MutuBuahPanenBodyState extends State<MutuBuahPanenBody> {
  final Map<int, TextEditingController> _controllers = {};
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();

    // Pastikan listOptional sudah terpanggil sekali di awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DetailProvider>(context, listen: false).listOptional();
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username')?.trim() ?? '';
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final prestasiProvider =
        Provider.of<PrestasiProvider>(context, listen: false);

    final panenProvider = Provider.of<PanenProvider>(context, listen: false);

    // Contoh ambil id dari argumen/route
    final noTransaksi =
        widget.initialNoTransaksi ?? panenProvider.notransaksi.toString();
    final noTph = widget.blok;
    final pemanen = prestasiProvider.selectedPemanen.toString();

    final provider = context.read<DetailProvider>();
    final savedDenda =
        provider.getDendaInput(noTransaksi, noTph.toString(), pemanen);
    final mutuList = context.read<DetailProvider>().listoptional;
    for (final item in mutuList) {
      final kode = item['kodedenda'].toString();
      final id = int.tryParse(item['iddenda'].toString()) ?? 0;
      final found = savedDenda.where((e) => e.kode == kode);
      if (found.isNotEmpty) {
        _controllers[id]?.text = found.first.value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutuList = context.watch<DetailProvider>().listoptional;

    return Consumer3<PanenProvider, PrestasiProvider, DetailProvider>(
      builder: (context, provider, prestasiProvider, detailProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...mutuList.map<Widget>((item) {
                  final id = int.tryParse(item['iddenda'].toString()) ?? 0;
                  final deskripsi = item['deskripsi'] ?? '';
                  final satuan = item['satuan'] ?? '';
                  final lockJjg = item['lockjjg'].toString() == '1';

                  // Inisialisasi controller kalau belum ada
                  _controllers.putIfAbsent(id, () => TextEditingController());

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$deskripsi ($satuan)',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        TextField(
                          controller: _controllers[id],
                          enabled: !lockJjg,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan jumlah',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      label: 'SIMPAN',
                      onPressed: () {
                        // Ambil hasil input dari seluruh field
                        final values = <int, String>{};
                        for (final id in _controllers.keys) {
                          values[id] = _controllers[id]!.text;
                        }

                        final List<DendaInput> dendaList = [];
                        for (final item in mutuList) {
                          final kode = item['kodedenda'].toString();
                          final id =
                              int.tryParse(item['iddenda'].toString()) ?? 0;

                          final value = _controllers[id]?.text ?? '';
                          dendaList.add(DendaInput(
                              kode: id.toString(),
                              value: value,
                              deskripsi: item['deskripsi']));
                        }
                        // print(dendaList);
                        // final provider = context.read<DetailProvider>();
                        detailProvider.saveMutuPanen(
                          noTransaksi: provider.notransaksi.toString(),
                          noTph: widget.blok.toString(),
                          pemanen: prestasiProvider.selectedPemanen.toString(),
                          dendaList: dendaList,
                        );

                        Navigator.pop(context);
                      },
                    ),
                    ActionButton(
                      color: Colors.grey,
                      label: 'BATAL',
                      onPressed: () {
                        for (final controller in _controllers.values) {
                          controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
