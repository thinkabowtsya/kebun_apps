import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/panen/gerdang_section.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/panen/detail_provider.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
// import 'package:flutter_application_3/services/FormMode.dart';
import 'package:flutter_application_3/services/notransaksihelper.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FormPrestasiPanenMode {
  add,
  edit,
}

class FormPrestasiPanenPage extends StatelessWidget {
  final FormPrestasiPanenMode mode;
  final String? notransaksi;
  final String? nik;

  const FormPrestasiPanenPage({
    super.key,
    this.mode = FormPrestasiPanenMode.add,
    this.notransaksi,
    this.nik,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == FormPrestasiPanenMode.add
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
  final FormPrestasiPanenMode mode;
  final String? notransaksi;
  final String? nik;

  const FormPrestasiPanenBody({
    super.key,
    this.mode = FormPrestasiPanenMode.add,
    this.notransaksi,
    this.nik,
  });

  @override
  State<FormPrestasiPanenBody> createState() => _FormPrestasiPanenBodyState();
}

class _FormPrestasiPanenBodyState extends State<FormPrestasiPanenBody> {
  final TextEditingController _noTransaksiController = TextEditingController();
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

      final panenProvider = Provider.of<PanenProvider>(context, listen: false);

      if (widget.mode == FormPrestasiPanenMode.edit &&
          widget.notransaksi != null) {
        await prestasiProvider.setFilterKaryawan('bygroup');
        await prestasiProvider.editPrestasi(
            notransaksi: widget.notransaksi, nik: widget.nik);
        await prestasiProvider.setPemanen(widget.nik.toString());
        await prestasiProvider.loadAfdeling();
      } else {
        prestasiProvider.loadAfdeling();
        prestasiProvider.setFilterKaryawan('bygroup');
        panenProvider.fetchPanenEvaluasi(panenProvider.notransaksi);
        prestasiProvider.loadDataprestasipanen(
            notransaksi: widget.notransaksi, pemanen: widget.nik);
        prestasiProvider.reset();
      }
    });
  }

  Future<bool> _loadKaryawanWithValidation(BuildContext context) async {
    return Future.microtask(() async {
      final provider = Provider.of<PrestasiProvider>(context, listen: false);
      final panenProvider = Provider.of<PanenProvider>(context, listen: false);
      final errors = await provider.loadkaryawan(
          'bygroup', panenProvider.selectedMandorValue);

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

    return Consumer3<PanenProvider, PrestasiProvider, DetailProvider>(
      builder: (context, provider, prestasiProvider, evaluasiProvider, _) {
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
                  prestasiProvider.loadDataprestasipanen(
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
                onSelected: (selectedId) {
                  prestasiProvider.setBlok(selectedId);
                  prestasiProvider.selectTph(selectedId);
                },
              ),
              const SizedBox(height: 8),
              const Text(
                "Tph",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              SearchableSelector(
                data: prestasiProvider.tph.map((item) {
                  return {
                    'id': item['key'].toString(),
                    'name': "${item['val']}",
                    'subtitle': '',
                  };
                }).toList(),
                labelText: 'Pilih Tph',
                onSelected: (selectedId) async {
                 
                  notphOnSelect = selectedId;

                  await Navigator.of(context).pushNamed(
                    '/detail-panen',
                    arguments: {
                      'blok': notphOnSelect,
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              CustomDataTableWidget(
                data: context.watch<PrestasiProvider>().listPrestasi,
                columns: const [
                  'blok',
                  'rotasi',
                  'jjgpanen',
                  'brondolanpanen',
                ],
                labelMapping: const {
                  'blok': 'TPH',
                  'rotasi': 'Sesi',
                  'jjgpanen': 'Jjg',
                  'brondolanpanen': 'Brondolan',
                },
                enableBottomSheet: true,
                bottomSheetActions: [
                  {
                    'label': 'Print',
                    'icon': Icons.print,
                    'colors': Colors.green,
                    'onTap': (row) => doPrint(row),
                  },
                  {
                    'label': 'Edit',
                    'icon': Icons.edit,
                    'colors': Colors.blue,
                    'onTap': (row) => doEdit(row),
                  },
                  {
                    'label': 'Hapus',
                    'icon': Icons.delete,
                    'colors': Colors.red,
                    'onTap': (row) => doDelete(row, context),
                  },
                ],
              ),
              const SizedBox(height: 8),
              ActionButton(
                label: 'SIMPAN',
                onPressed: () async {
                  provider.setShouldRefresh(true);
                  Navigator.pop(context);
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  void doPrint(row) async {
    await Navigator.of(context).pushNamed(
      '/print-qr',
      arguments: {
        'noTransaksi': row['notransaksi'].toString(),
        'blok': row['blok'].toString(),
        'rotasi': row['rotasi'].toString(),
        'nik': row['nik'].toString(),
      },
    );
  }

  void doEdit(row) async {
    await Navigator.of(context).pushNamed(
      '/edit-detail',
      arguments: {
        'noTransaksi': row['notransaksi'].toString(),
        'rotasi': row['rotasi'].toString(),
        'blok': row['blok'].toString(),
        'nik': row['nik'].toString(),
        'notph': row['blok']
      },
    );
  }

  void doDelete(row, BuildContext context) async {
    final detailProvider = Provider.of<DetailProvider>(context, listen: false);
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
      await detailProvider.deleteDataDetail(
          notransaksi: row['notransaksi'].toString(),
          nik: row['nik'].toString(),
          blok: row['blok'].toString(),
          rotasi: row['rotasi'].toString());

      prestasiProvider.loadDataprestasipanen(
          notransaksi: row['notransaksi'], pemanen: row['nik']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
        ),
      );
    }
  }
}
