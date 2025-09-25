import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/Qr.dart';
import 'package:flutter_application_3/pages/haprestasipanen/prestasipanen.dart';
import 'package:flutter_application_3/pages/panen/prestasipanen.dart';
import 'package:flutter_application_3/pages/widget/camera.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/haprestasipanen/haprestasipanen_provider.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
import 'package:flutter_application_3/providers/spb/spb_provider.dart';
// import 'package:flutter_application_3/services/FormMode.dart';
import 'package:flutter_application_3/services/notransaksihelper.dart';
import 'package:flutter_application_3/utils/image_helper.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:flutter_application_3/widget/kernetTable.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FormSpbMode {
  add,
  edit,
}

class FormSpbPage extends StatelessWidget {
  final FormSpbMode mode;
  final String? initialNoTransaksi;
  final DateTime? initialTanggal;

  const FormSpbPage({
    super.key,
    this.mode = FormSpbMode.add,
    this.initialNoTransaksi,
    this.initialTanggal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(mode == FormSpbMode.add ? 'Transaksi Baru' : 'Edit Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: FormSpbBody(
        mode: mode,
        initialNoTransaksi: initialNoTransaksi,
        initialTanggal: initialTanggal,
      ),
    );
  }
}

Uint8List? _capturedBytes; // untuk preview dari base64

// String? encodeBase64Image(Uint8List? bytes) =>
//     (bytes == null || bytes.isEmpty) ? null : base64Encode(bytes);

class FormSpbBody extends StatefulWidget {
  final FormSpbMode mode;
  final String? initialNoTransaksi;
  final DateTime? initialTanggal;

  const FormSpbBody({
    super.key,
    this.mode = FormSpbMode.add,
    this.initialNoTransaksi,
    this.initialTanggal,
  });

  @override
  State<FormSpbBody> createState() => _FormSpbBodyState();
}

class _FormSpbBodyState extends State<FormSpbBody> {
  final TextEditingController _noTransaksiController = TextEditingController();
  String _username = '';
  String _tipepks = 'PKS Tujuan';
  List<Map<String, dynamic>> tesListDinamis = [];
  File? _capturedImage;
  int _selectedPresenceOption = 1;
  String _pksTujuaninit = '';
  bool _isLoadingPks = false;
  String? _base64Image;
  File? _previewFile;

  bool _changed1 = false;

  String? _pathFoto1;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialTanggal ?? DateTime.now();
    _loadUsername();
    final provider = Provider.of<SpbProvider>(context, listen: false);

    // Future.microtask(() {
    //   provider.fetchPanenEvaluasiHa(_noTransaksiController.text);
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.mode == FormSpbMode.edit &&
          widget.initialNoTransaksi != null) {
        _noTransaksiController.text = widget.initialNoTransaksi!;
        _selectedDate = widget.initialTanggal ?? DateTime.now();
        await _changeStatusPks(provider.selectedstatus.toString());
        await provider.fetchSpb();
        await provider.fetchDriver();
        await provider.fetchVehicle();
        await provider.fetchTkbm();

        provider.setTanggal(_selectedDate);
        provider.setNotransaksi(_noTransaksiController.text);
        provider.editSpb(_noTransaksiController.text);

        _base64Image = provider.selectedImage;

        print(_base64Image);
        provider.getListSpbdetail(_noTransaksiController.text);
        // final bytes1 = await resolveImage(_capturedImage, _base64Image);
        // final file = await bytesToTempFile(bytes1!);

        // print('foto $file');

        // provider.setImage(file);

        // final bytes1 = await resolveImage(_capturedImage, _base64Image);
        // if (bytes1 != null) {
        //   final file = await bytesToTempFile(bytes1);
        //   if (!mounted) return;
        //   setState(() {
        //     _previewFile = file;
        //     _capturedImage = file;
        //   });
        //   provider.setImage(file);
        // }

        if (_looksLikeFilePath(_base64Image!)) {
          final f = File(_base64Image!);
          if (await f.exists()) {
            setState(() {
              _pathFoto1 = _base64Image;
              _previewFile = f;
            });
          }
        }

        setState(() {
          _showDetailTable = true;
          _pksTujuaninit = provider.selectedStatuspks.toString();
        });
      } else {
        provider.resetForm();
        provider.fetchSpb();
        provider.fetchDriver();
        provider.fetchVehicle();
        provider.fetchTkbm();

        final notransaksi = await NoTransaksiHelper()
            .generateNoTransaksi(nametable: 'kebun_spbht');
        _noTransaksiController.text = notransaksi;
        provider.setNotransaksi(_noTransaksiController.text);
        provider.setTanggal(_selectedDate);
        setState(() {
          _selectedPresenceOption = 1;
        });
        // // await provider.fetchByTrans(_noTransaksiController.text);
      }
    });
  }

  bool _looksLikeFilePath(String s) {
    // Android internal app dir -> /data/user/0/...
    // Juga cover "file://", atau Windows path saat dev
    return s.startsWith('/data/') ||
        s.startsWith('/storage/') ||
        s.startsWith('file://') ||
        s.contains(':\\');
  }

  bool _looksLikeBase64(String s) {
    if (s.isEmpty) return false;
    final rx = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return s.length % 4 == 0 && rx.hasMatch(s);
  }

  Future<File> _base64ToTempFile(String b64,
      {String prefix = 'from_db_'}) async {
    final bytes = base64Decode(b64);
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/$prefix${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _loadPksFor(String? statusId, {String? initialPksId}) async {
    final provider = Provider.of<SpbProvider>(context, listen: false);

    if (statusId == null || statusId.isEmpty) {
      // kosongin aja kalau status belum ada
      if (!mounted) return;
      setState(() {
        tesListDinamis = [];
        _pksTujuaninit = '';
      });
      return;
    }

    if (mounted) setState(() => _isLoadingPks = true);

    try {
      // ⚠️ WAJIB di-await, jangan fire-and-forget
      final rows = await provider.fetStatusPksDinamis(statusId, null);

      // normalisasi & map ke String
      final list = rows
          .map<Map<String, String>>((r) => {
                'id': (r['id'] ?? r['value'] ?? '').toString(),
                'name': (r['name'] ?? r['label'] ?? '').toString(),
                'subtitle': (r['subtitle'] ?? '').toString(),
              })
          .toList();

      // validasi initial id ada di data
      final init = (initialPksId ?? provider.selectedStatuspks?.toString());
      final exists = init != null && list.any((e) => e['id'] == init);

      if (!mounted) return;
      setState(() {
        tesListDinamis = list;
        _pksTujuaninit = exists ? init : '';
      });
    } finally {
      if (mounted) setState(() => _isLoadingPks = false);
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final provider = Provider.of<PanenProvider>(context, listen: false);
  //   if (provider.shouldRefresh) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       context
  //           .read<PanenProvider>()
  //           .fetchPanenEvaluasi(_noTransaksiController.text);

  //       provider.setShouldRefresh(false);
  //     });
  //   }
  // }

  @override
  void dispose() {
    _noTransaksiController.dispose();

    super.dispose();
  }

  List<Map<String, dynamic>> listStatusPks = [
    {'label': '', 'value': ''},
    {'label': 'Internal', 'value': '0'},
    {'label': 'Afiliasi', 'value': '1'},
    {'label': 'TPB', 'value': '2'},
    {'label': 'External', 'value': '3'},
    {'label': 'Peron', 'value': '4'},
  ];

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username')?.trim() ?? '';
    });
  }

  DateTime _selectedDate = DateTime.now();

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final provider = Provider.of<SpbProvider>(context, listen: false);
        provider.setTanggal(_selectedDate);
      });
    }
  }

  bool _showDetailTable = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<SpbProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// === HEADER SECTION ===
                ExpansionTile(
                  initiallyExpanded: true,
                  title: const Align(
                    alignment: Alignment.centerLeft, // judul tile rata kiri
                    child: Text(
                      "Header SPB",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // semua label rata kiri
                        children: [
                          const SizedBox(height: 8),
                          const Text("No Transaksi",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _noTransaksiController,
                            enabled: false,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("Tanggal",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          GestureDetector(
                            onTap: widget.mode != FormSpbMode.edit
                                ? _showDatePicker
                                : null,
                            child: AbsorbPointer(
                              child: TextField(
                                readOnly: true,
                                enabled: widget.mode != FormSpbMode.edit,
                                decoration: InputDecoration(
                                  hintText: '${_selectedDate.toLocal()}'
                                      .split(' ')[0],
                                  suffixIcon: const Icon(Icons.calendar_today),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("Afdeling",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          const SizedBox(height: 8),
                          SearchableSelector(
                            data: provider.afdelinglist.map((item) {
                              return {
                                'id': item['key'].toString(),
                                'name': item['val'],
                                'subtitle': "",
                              };
                            }).toList(),
                            labelText: 'Pilih Afdeling',
                            initialId: provider.selectedAfdeling,
                            onSelected: (selectedId) {
                              provider.setAfdeling(selectedId.toString());
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text("Krani Transport",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          SearchableSelector(
                            data: provider.kraniproduksilist.map((item) {
                              return {
                                'id': item['karyawanid'].toString(),
                                'name': item['namakaryawan'],
                                'subtitle':
                                    "${item['subbagian']} | ${item['nik']}",
                              };
                            }).toList(),
                            labelText: 'Pilih Krani',
                            initialId: provider.selectedKrani,
                            onSelected: (selectedId) {
                              provider.setKrani(selectedId.toString());
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text("Status Tujuan",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          SearchableSelector(
                            data: listStatusPks.map((item) {
                              return {
                                'id': item['value'].toString(),
                                'name': item['label'],
                                'subtitle': "",
                              };
                            }).toList(),
                            labelText: 'Status Tujuan',
                            initialId: provider.selectedstatus,
                            onSelected: (selectedId) {
                              provider.setStatus(selectedId.toString());
                              _changeStatusPks(selectedId.toString());
                            },
                          ),
                          Text(provider.labelpks.toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          const SizedBox(height: 8),
                          SearchableSelector(
                            data: tesListDinamis,
                            labelText: 'Pilih Status Pks',
                            initialId: _pksTujuaninit,
                            onSelected: (selectedId) {
                              provider.setStatusPks(selectedId.toString());
                            },
                          ),
                          const Text("Kernet",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          KernetTable(
                            provider: provider,
                            initialRows: provider.kernetOnSpb,
                            onChanged: (rows) {
                              provider.setKernetList(rows);
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text("Nama Supir",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          SearchableSelector(
                            data: provider.driverlist.map((item) {
                              return {
                                'id': item['karyawanid'].toString(),
                                'name': item['namakaryawan'],
                                'subtitle':
                                    "${item['subbagian']} | ${item['nik']}",
                              };
                            }).toList(),
                            labelText: 'Pilih Supir',
                            initialId: provider.selectedDriver,
                            onSelected: (selectedId) {
                              provider.setDriver(selectedId.toString());
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text("Nomor Polisi",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          SearchableSelector(
                            data: provider.vehicleList.map((item) {
                              return {
                                'id': item['key'].toString(),
                                'name': item['val'],
                                'subtitle': "",
                              };
                            }).toList(),
                            labelText: 'Pilih No Polisi',
                            initialId: provider.selectedVehicle,
                            onSelected: (selectedId) {
                              provider.setKendaraan(selectedId.toString());
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text("Foto",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start),
                          ActionButton(
                            color: Colors.blue.shade900,
                            label: 'AMBIL FOTO',
                            onPressed: _addPicture,
                          ),
                          (_previewFile != null)
                              ? SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Image.file(
                                    _previewFile!,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : const Text("Belum ada foto"),
                          const SizedBox(height: 12),
                          ActionButton(label: 'SIMPAN', onPressed: _simpan),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),

                /// === DETAIL SECTION ===
                ExpansionTile(
                  initiallyExpanded: true,
                  title: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Detail SPB",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Transaksi Detail'),
                          RadioListTile(
                            value: 1,
                            groupValue: _selectedPresenceOption,
                            title: const Text("Normal"),
                            onChanged: (value) {
                              setState(() {
                                _selectedPresenceOption = value!;
                              });
                            },
                          ),
                          RadioListTile(
                            value: 2,
                            groupValue: _selectedPresenceOption,
                            title: const Text('Double Handling'),
                            onChanged: (value) {
                              setState(() {
                                _selectedPresenceOption = value!;
                              });
                            },
                          ),
                          ActionButton(
                            color: Colors.blue.shade900,
                            label: 'SCAN QR',
                            onPressed: _openCameraSqanQr,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Data Surat Pengiriman Buah",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          CustomDataTableWidget(
                            data: context.read<SpbProvider>().spbDetailList,
                            columns: const [
                              'blok',
                              'nik_nama',
                              'rotasi',
                              'sFilename',
                              'jjg',
                              'brondolan',
                            ],
                            labelMapping: const {
                              'tph': 'tph/noSpb',
                              'nik_nama': 'Nik',
                              'rotasi': 'Sesi',
                              'sFilename': 'Status',
                              'jjg': 'Jjg',
                              'brondolan': 'Brondolan',
                            },
                            enableBottomSheet: true,
                            bottomSheetActions: [
                              {
                                'label': 'Hapus',
                                'colors': Colors.red,
                                'icon': Icons.delete,
                                'onTap': (row) => doDelete(row, context),
                              },
                            ],
                          ),
                        ],
                      ),
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

  void _addPicture() async {
    final provider = context.read<SpbProvider>();
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const CameraCapturePage(filePrefix: 'foto')),
    );

    if (!mounted || result == null) return;

    setState(() {
      _previewFile = result;
      // _capturedImage = result;
      _pathFoto1 = result.path;
      _changed1 = true;
    });
    provider.setImage(_pathFoto1);
  }

  Future<void> _changeStatusPks(String tipeId) async {
    final provider = Provider.of<SpbProvider>(context, listen: false);
    final item1 = await provider.fetStatusPksDinamis(tipeId, '');

    setState(() {
      tesListDinamis = item1;
    });
  }

  void _simpan() async {
    final provider = Provider.of<SpbProvider>(context, listen: false);

    final errors = await provider.simpanSpb();

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
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil simpan header")),
      );
    }
  }

  void doDelete(row, BuildContext context) async {
    final provider = Provider.of<SpbProvider>(context, listen: false);

    print('row detail $row');
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
      await provider.deleteSpbDetail(
          notransaksi: _noTransaksiController.text,
          blok: row['blok'].toString(),
          nospbref: row['nospbref'].toString(),
          rotasi: row['rotasi'].toString(),
          nik: row['karyawanid'].toString());

      // await detailProvider.deleteDataDetail(
      //     notransaksi: row['notransaksi'].toString(),
      //     nik: row['nik'].toString(),
      //     blok: row['blok'].toString(),
      //     rotasi: row['rotasi'].toString());

      // prestasiProvider.loadDataprestasipanen(
      //     notransaksi: row['notransaksi'], pemanen: row['nik']);

      setState(() {
        provider.getListSpbdetail(_noTransaksiController.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
        ),
      );
    }
  }

  void _openCameraSqanQr() async {
    final provider = Provider.of<SpbProvider>(context, listen: false);

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          onScan: (val) {
            print("Callback langsung jalan: $val");

            return;
          },
        ),
      ),
    );

    if (result != null) {
      final qrValue = result as String;
      final data = parseQrResult(qrValue);

      // Ambil satu field saja
      final kerani = data['kerani'];

      final tipespb = data['mode'];

      // print("mode: $tipespb");
      // print(_selectedPresenceOption.toString());

      final errors = await provider.spbResultScan(
          data, _selectedPresenceOption.toString());

      print('ada error masuk $errors');
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
        return;
      }

      provider.getListSpbdetail(provider.notransaksi);
    }
  }

  Map<String, dynamic> parseQrResult(String qrValue) {
    String _get(List<String> arr, int i) =>
        (i >= 0 && i < arr.length) ? arr[i] : '';

    // ==== MODE 1: PANEN NORMAL (delimiter: |) ====
    if (qrValue.contains('|')) {
      final parts = qrValue.split('|');

      final String noTph = _get(parts, 0);
      final String noTransaksi = _get(parts, 1);
      final String pemanenNik = _get(parts, 2);
      final int jjg = int.tryParse(_get(parts, 3)) ?? 0;
      final int brondolan = int.tryParse(_get(parts, 4)) ?? 0;
      final String tanggal = _get(parts, 5);
      final String status = _get(parts, 6);
      final String cetakan = _get(parts, 7);
      final String rotasi = _get(parts, 8);
      final String mandor2 = _get(parts, 9);
      final String mandor1 = _get(parts, 10);
      final String asisten = _get(parts, 11);
      final String kerani = _get(parts, 12);
      // parts[13] biasanya kosong / cadangan
      // parts[14] bisa berisi "g#BMA:2;BTA:4" (opsional)

      // === parsing denda dinamis (opsional) ===
      final List<Map<String, dynamic>> dendaList = [];
      final String dendaPart = _get(parts, 14);
      if (dendaPart.isNotEmpty && dendaPart.startsWith('g#')) {
        final dendaStr = dendaPart.substring(2); // setelah "g#"
        for (final item in dendaStr.split(';')) {
          final t = item.trim();
          if (t.isEmpty) continue;
          final kv = t.split(':');
          if (kv.length == 2) {
            dendaList.add({
              "kode": kv[0],
              "jumlah": int.tryParse(kv[1]) ?? 0,
            });
          }
        }
      }

      final result = {
        "mode": "1",
        "noTph": noTph,
        "noTransaksi": noTransaksi,
        "pemanenNik": pemanenNik,
        "jjg": jjg,
        "brondolan": brondolan,
        "tanggal": tanggal,
        "status": status,
        "cetakan": cetakan,
        "rotasi": rotasi,
        "mandor1": mandor1,
        "mandor2": mandor2,
        "kerani": kerani,
        "asisten": asisten,
        "denda": dendaList,
        "raw": qrValue,
      };

      // debug
      // result.forEach((k, v) => print("$k: $v"));
      return result;
    }

    // ==== MODE 2: SPB DOUBLE HANDLING (delimiter: #, diawali * dan diakhiri $ / ##$) ====
    if (qrValue.contains('#')) {
      // bersihkan marker awal/akhir
      String s = qrValue.trim();
      s = s.replaceFirst(RegExp(r'^\*'), ''); // buang '*' di depan
      s = s.replaceFirst(
          RegExp(r'\$+$'), ''); // buang satu/lebih '$' di belakang

      // split lalu buang field kosong di tail (kasus '##' sebelum '$')
      final parts = s.split('#');
      while (parts.isNotEmpty && parts.last.isEmpty) {
        parts.removeLast();
      }

      // Berdasar contoh:
      // "*KSLE2025091109442174-002#DEDI AFRIANDI#BK9SRH#16#2012#3#KSLE#01##$"
      // Layout paling sering:
      // [0]=noTransaksi(berawalan estate), [1]=nama, [2]=afdeling, [3]=jjg,
      // [4]=kodeorgAtauBlok, [5]=rotasi, [6]=estate, [7]=divisi
      // (Beberapa implementasi bisa beda urutan — adjust jika perlu)
      final map = {
        "mode": "2",
        "noTransaksi": _get(parts, 0),
        "nama": _get(parts, 1),
        "afdeling": _get(parts, 2),
        "jjg": int.tryParse(_get(parts, 3)) ?? 0,
        "tahuntanam": _get(parts, 4),
        "brondolan": _get(parts, 5),
        "estate": _get(parts, 6),
        "divisi": _get(parts, 7),
        "rawTokens": parts,
        "raw": qrValue,
      };

      // debug
      // map.forEach((k, v) => print("$k: $v"));
      return map;
    }

    throw FormatException('QR tidak dikenali formatnya: $qrValue');
  }
}
