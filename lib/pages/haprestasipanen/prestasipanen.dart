import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/panen/gerdang_section.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/haprestasipanen/haprestasipanen_provider.dart';
import 'package:flutter_application_3/providers/haprestasipanen/prestasi_provider.dart';
import 'package:flutter_application_3/providers/panen/detail_provider.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
// import 'package:flutter_application_3/services/FormMode.dart';
import 'package:flutter_application_3/services/notransaksihelper.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HAPrestasiPanenMode {
  add,
  edit,
}

class HAPrestasiPanenPage extends StatelessWidget {
  final HAPrestasiPanenMode mode;
  final String? notransaksi;
  final String? nik;

  const HAPrestasiPanenPage({
    super.key,
    this.mode = HAPrestasiPanenMode.add,
    this.notransaksi,
    this.nik,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == HAPrestasiPanenMode.add
            ? 'Transaksi Baru'
            : 'Edit Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: FormPrestasiPanenBody(
        mode: mode,
        notransaksi: notransaksi,
        nik: nik,
      ),
    );
  }
}

class FormPrestasiPanenBody extends StatefulWidget {
  final HAPrestasiPanenMode mode;
  final String? notransaksi;
  final String? nik;

  const FormPrestasiPanenBody({
    super.key,
    this.mode = HAPrestasiPanenMode.add,
    this.notransaksi,
    this.nik,
  });

  @override
  State<FormPrestasiPanenBody> createState() => _FormPrestasiPanenBodyState();
}

class _FormPrestasiPanenBodyState extends State<FormPrestasiPanenBody> {
  final TextEditingController _noTransaksiController = TextEditingController();
  final TextEditingController _luasBlokController = TextEditingController();
  final TextEditingController _luasPanenController = TextEditingController();
  String _username = '';
  String _notph = '';
  String selectedValue = 'bygroup';
  String notphOnSelect = '';
  @override
  void initState() {
    super.initState();

    _loadUsername();
    _loadKaryawanWithValidation(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prestasiProvider =
          Provider.of<PrestasiProvider>(context, listen: false);

      // final panenProvider = Provider.of<PanenProvider>(context, listen: false);

      if (widget.mode == HAPrestasiPanenMode.edit &&
          widget.notransaksi != null) {
        await prestasiProvider.setFilterKaryawan('bygroup');
        // await prestasiProvider.editPrestasi(
        //     notransaksi: widget.notransaksi, nik: widget.nik);
        await prestasiProvider.setPemanen(widget.nik.toString());
        await prestasiProvider.loadAfdeling();
      } else {
        prestasiProvider.loadAfdeling();
        prestasiProvider.setFilterKaryawan('bygroup');
        // panenProvider.fetchPanenEvaluasi(panenProvider.notransaksi);
        // prestasiProvider.loadDataprestasipanen(
        //     notransaksi: widget.notransaksi, pemanen: widget.nik);
        // prestasiProvider.reset();
      }
    });
  }

  Future<bool> _loadKaryawanWithValidation(BuildContext context) async {
    return Future.microtask(() async {
      final provider = Provider.of<PrestasiProvider>(context, listen: false);
      final prestasiProvider =
          Provider.of<HaPrestasiPanenProvider>(context, listen: false);
      final errors = await provider.loadkaryawan(
          'bygroup', prestasiProvider.selectedMandorValue);

      if (errors.isNotEmpty) {
        await showDialog(
          context: context,
          useRootNavigator: false,
          builder: (_) => AlertDialog(
            title: const Text('Validasi Gagal'),
            content: Text(errors.join('\n')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return false;
      }

      return true;
    });
  }

  @override
  void dispose() {
    _noTransaksiController.dispose();

    super.dispose();
  }

  DateTime _selectedDate = DateTime.now();
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username')?.trim() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    String noTrans = _noTransaksiController.text;

    final List<Map<String, String>> filterkaryawan = [
      {'value': 'all', 'label': 'Seluruhnya'},
      {'value': 'bygroup', 'label': 'Kemandoran'},
      {'value': 'bydivision', 'label': 'Divisi'},
    ];

    return Consumer2<HaPrestasiPanenProvider, PrestasiProvider>(
      builder: (context, provider, prestasiProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Filter Karyawan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: prestasiProvider.selectedFilterkaryawan,
                  items: filterkaryawan.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(item['label'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value!;
                      prestasiProvider.setFilterKaryawan(value);
                      prestasiProvider.loadkaryawan(
                          value, provider.selectedMandorValue);
                    });
                  },
                  isDense: false,
                  elevation: 1,
                ),
              ),
              const Text(
                "Pemanen",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              SearchableSelector(
                data: prestasiProvider.karyawan.map((item) {
                  return {
                    'id': item['karyawanid'].toString(),
                    'name': item['namakaryawan'],
                    'subtitle': "${item['subbagian']} | ${item['nik']}",
                  };
                }).toList(),
                labelText: 'Pilih Pemanen',
                initialId: widget.nik, //
                onSelected: (selectedId) {
                  prestasiProvider.setPemanen(selectedId);
                  prestasiProvider.loadPrestasiHaPanen(
                      pemanen: prestasiProvider.selectedPemanen,
                      notransaksi: provider.notransaksi);
                },
              ),
              const SizedBox(height: 8),
              const Text(
                "Afdeling",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
                  value: prestasiProvider.selectedAfdeling,
                  items: prestasiProvider.afdeling.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['key'],
                      child: Text(item['val'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      prestasiProvider.setAfdeling(value!);
                      prestasiProvider.selectBlok(value);
                    });
                  },
                  hint: const Text("Pilih Afd"),
                  isDense: false,
                  elevation: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Blok",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              SearchableSelector(
                data: prestasiProvider.blok.map((item) {
                  return {
                    'id': item['key'].toString(),
                    'name': "${item['val']} ",
                    'subtitle': '',
                  };
                }).toList(),
                labelText: 'Pilih Blok',
                onSelected: (selectedId) async {
                  prestasiProvider.setBlok(selectedId);
                  await prestasiProvider.selectTphHA(selectedId);
                  _luasBlokController.text = prestasiProvider.luasareaproduktif;
                  // prestasiProvider.selectTph(selectedId);
                },
              ),
              const SizedBox(height: 8),
              const Text(
                "Luas Blok (HA)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              TextField(
                controller: _luasBlokController,
                textAlign: TextAlign.start,
                focusNode: FocusNode(canRequestFocus: false),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
              const SizedBox(height: 8),
              const Text(
                "Luas Panen (HA)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              TextField(
                controller: _luasPanenController,
                textAlign: TextAlign.start,
                focusNode: FocusNode(canRequestFocus: false),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ActionButton(
                label: 'SIMPAN',
                onPressed: () async {
                  _simpanEvaluasi();
                  // provider.setShouldRefresh(true);
                  // Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              // GerdangSection(),
              CustomDataTableWidget(
                data: context.watch<PrestasiProvider>().listPrestasi,
                columns: const [
                  'blok',
                  'namakaryawan',
                  'luaspanen',
                ],
                labelMapping: const {
                  'blok': 'Blok',
                  'namakaryawan': 'Nama',
                  'luaspanen': 'Luas (HA)',
                },
                enableBottomSheet: true,
                bottomSheetActions: [
                  {
                    'label': 'Hapus',
                    'icon': Icons.delete,
                    'colors': Colors.red,
                    'onTap': (row) => doDelete(row, context),
                  },
                ],
              ),
            ]),
          ),
        );
      },
    );
  }

  void _simpanEvaluasi() async {
    final provider =
        Provider.of<HaPrestasiPanenProvider>(context, listen: false);
    final prestasiProvider =
        Provider.of<PrestasiProvider>(context, listen: false);
    String? notransaksi = provider.notransaksi;
    DateTime tgltransaksi = provider.tanggal;

    final errors = <String>[];

    try {
      final errors = await prestasiProvider.addEvaluasi(
          notransaksi: notransaksi,
          tgltransaksi: tgltransaksi,
          luasblok: _luasBlokController.text,
          luaspanen: _luasPanenController.text);

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
      } else {
        await prestasiProvider.loadPrestasiHaPanen(
            pemanen: prestasiProvider.selectedPemanen,
            notransaksi: provider.notransaksi);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan')),
      );
    }
  }

  void doDelete(row, BuildContext context) async {
    print(row);
    final prestasiProvider =
        Provider.of<PrestasiProvider>(context, listen: false);

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
      print(row);
      await prestasiProvider.deleteEvaluasi(
        notransaksi: row['notransaksi'].toString(),
        nik: row['nik'].toString(),
        blok: row['blok'].toString(),
      );

      prestasiProvider.loadPrestasiHaPanen(
          notransaksi: row['notransaksi'], pemanen: row['nik']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
        ),
      );
    }
  }
}
