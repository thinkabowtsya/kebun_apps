import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/addKehadiran.dart';
import 'package:flutter_application_3/pages/widget/camera.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/kehadiran_provider.dart';
import 'package:flutter_application_3/providers/bkm/material_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
import 'package:flutter_application_3/services/FormMode.dart';
import 'package:flutter_application_3/services/photo_helper.dart';
import 'package:flutter_application_3/utils/image_helper.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class EditPrestasiPage extends StatelessWidget {
  final String? kodekegiatan;
  EditPrestasiPage({super.key, this.kodekegiatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaksi'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: EditPrestasiBody(),
    );
  }
}

class EditPrestasiBody extends StatefulWidget {
  final String? kodekegiatan;
  EditPrestasiBody({super.key, this.kodekegiatan});

  @override
  State<EditPrestasiBody> createState() => _EditPrestasiBodyState();
}

class _EditPrestasiBodyState extends State<EditPrestasiBody> with RouteAware {
  final TextEditingController _noTransaksiController = TextEditingController();
  CameraController? _cameraController;

  File? _watermarkedImage1;
  File? _watermarkedImage2;
  bool _isTakingPicture1 = false;
  bool _isTakingPicture2 = false;
  Position? _currentPosition;
  bool _isTakingPicture = false;
  String? _base64Image1;
  String? _base64Image2;

  File? _previewFile1;
  File? _capturedImage1;

  File? _previewFile2;
  File? _capturedImage2;

  String? _pathFoto1;
  String? _pathFoto2;

  bool _changed1 = false;
  bool _changed2 = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();

    final bkmProv = Provider.of<BkmProvider>(context, listen: false);
    final noTransaksi = bkmProv.notransaksi;
    String? kodekegiatanTemp = bkmProv.kodekegiatanTemp;
    String? kodeorgTemp = bkmProv.kodeorgTemp;
    double? luasareaproduktifTemp = bkmProv.luasproduktifTemp;
    double? luaspokokTemp = bkmProv.luaspokokTemp;

    _loadDataFromDB(kodekegiatanTemp, kodeorgTemp);

    kehadiranList(
        notransaksi: noTransaksi.toString(),
        kodekegiatan: kodekegiatanTemp.toString(),
        kodeorg: kodeorgTemp.toString(),
        kelompok: '',
        luasareaproduktif: luasareaproduktifTemp.toString());
  }

  Future<void> kehadiranList({
    String notransaksi = '',
    String kodekegiatan = '',
    String kodeorg = '',
    String kelompok = '',
    String luasareaproduktif = '',
  }) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final materialProvider =
          Provider.of<MaterialProvider>(context, listen: false);
      materialProvider.fetchMaterialByBkm(
          notrans: notransaksi, kodekegiatan: kodekegiatan, kodeorg: kodeorg);
      final listing =
          await Provider.of<KehadiranProvider>(context, listen: false)
              .fetchKehadiranByTransaksi(
                  notransaksi: notransaksi,
                  kodekegiatan: kodekegiatan,
                  kodeorg: kodeorg,
                  kelompok: kelompok,
                  luasareaproduktif: luasareaproduktif);

      Provider.of<KehadiranProvider>(context, listen: false)
          .setKehadiranList(listing);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<KehadiranProvider>(context, listen: false);
    final materialProvider =
        Provider.of<MaterialProvider>(context, listen: false);
    final bkmProv = Provider.of<BkmProvider>(context, listen: false);
    final noTransaksi = bkmProv.notransaksi;
    String? kodekegiatanTemp = bkmProv.kodekegiatanTemp;
    String? kodeorgTemp = bkmProv.kodeorgTemp;
    double? luasareaproduktifTemp = bkmProv.luasproduktifTemp;
    double? luaspokokTemp = bkmProv.luaspokokTemp;

    if (provider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<KehadiranProvider>().fetchKehadiranByTransaksi(
            notransaksi: noTransaksi,
            kodekegiatan: kodekegiatanTemp,
            kodeorg: kodeorgTemp,
            kelompok: luasareaproduktifTemp.toString(),
            luasareaproduktif: luaspokokTemp.toString());

        provider.setShouldRefresh(false);
      });
    }
    // print('refresh material');

    if (materialProvider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        materialProvider.fetchMaterialByBkm(
            notrans: noTransaksi,
            kodekegiatan: kodekegiatanTemp,
            kodeorg: kodeorgTemp);

        materialProvider.setShouldRefresh(false);
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize camera')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location permissions are permanently denied')),
          );
        }
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location')),
        );
      }
    }
  }

  // void _loadDataFromDB(String? kodekegiatan, String? kodeorg) async {
  //   final provider = Provider.of<PrestasiProvider>(context, listen: false);

  //   final result = await provider.fetchPhotoAkhir(
  //       kodekegiatan.toString(), kodeorg.toString());

  //   if (result.isNotEmpty) {
  //     setState(() {
  //       _base64Image1 = result.first['jumlahhasilkerja'];
  //       _base64Image2 = result.first['fotoend2'];
  //     });
  //   }

  //   final bytes1 = await resolveImage(_capturedImage1, _base64Image1);
  //   final bytes2 = await resolveImage(_capturedImage2, _base64Image2);
  //   if (bytes1 != null || bytes2 != null) {
  //     final file1 = await bytesToTempFile(bytes1!);
  //     final file2 = await bytesToTempFile(bytes2!);
  //     if (!mounted) return;

  //     setState(() {
  //       _previewFile1 = file1;
  //       _capturedImage1 = file1;

  //       _previewFile2 = file2;
  //       _capturedImage2 = file2;
  //     });
  //     // detailProvider.setImage(file);
  //   }
  // }
  Future<void> _loadDataFromDB(String? kodekegiatan, String? kodeorg) async {
    final prestasi = await context
        .read<PrestasiProvider>()
        .fetchPhotoAkhir(kodekegiatan.toString(), kodeorg.toString());

    if (prestasi.isEmpty) return;

    // Kolom di DB: tetap pakai nama lama (mis. jumlahhasilkerja, fotoend2)
    final v1 = (prestasi.first['jumlahhasilkerja'] ?? '').toString();
    final v2 = (prestasi.first['fotoend2'] ?? '').toString();

    // Foto 1
    if (_looksLikeFilePath(v1)) {
      final f = File(v1);
      if (await f.exists()) {
        setState(() {
          _pathFoto1 = v1;
          _previewFile1 = f;
        });
      }
    } else if (_looksLikeBase64(v1)) {
      // fallback kompatibilitas data lama
      final f = await _base64ToTempFile(v1, prefix: 'db_foto1_');
      setState(() {
        _pathFoto1 = f.path; // opsional simpan lagi path-nya
        _previewFile1 = f;
      });
    }

    // Foto 2
    if (_looksLikeFilePath(v2)) {
      final f = File(v2);
      if (await f.exists()) {
        setState(() {
          _pathFoto2 = v2;
          _previewFile2 = f;
        });
      }
    } else if (_looksLikeBase64(v2)) {
      final f = await _base64ToTempFile(v2, prefix: 'db_foto2_');
      setState(() {
        _pathFoto2 = f.path;
        _previewFile2 = f;
      });
    }
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

  @override
  void dispose() {
    _noTransaksiController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataKehadiran = context.watch<KehadiranProvider>().kehadiranList;
    final dataMaterial = context.watch<MaterialProvider>().materialList;

    return Consumer4<BkmProvider, PrestasiProvider, KehadiranProvider,
            MaterialProvider>(
        builder: (context, provider, prestasiProvider, kehadiranProvider,
            materialProvider, _) {
      final noTransaksi = provider.notransaksi;
      String? kodekegiatanTemp = provider.kodekegiatanTemp;
      String? kodeorgTemp = provider.kodeorgTemp;
      double? luasareaproduktifTemp = provider.luasproduktifTemp;
      double? luaspokokTemp = provider.luaspokokTemp;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Data Kehadiran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                fontSize: 20,
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await Navigator.of(context)
                            .pushNamed('/add-kehadiran')
                            .then((value) {
                          setState(() {
                            kehadiranProvider.fetchKehadiranByTransaksi(
                                notransaksi: noTransaksi,
                                kodekegiatan: kodekegiatanTemp,
                                kodeorg: kodeorgTemp,
                                kelompok: luasareaproduktifTemp.toString(),
                                luasareaproduktif: luaspokokTemp.toString());
                          });
                        });
                        ;
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: const Text('Tambah'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            const Color.fromARGB(255, 90, 157, 211),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: const Text('Kemandoran'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                border: TableBorder.all(color: Colors.grey),
                headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                dataRowHeight: 32,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Nama Karyawan')),
                  DataColumn(label: Text('HK')),
                  DataColumn(label: Text('Hasil Kerja')),
                  DataColumn(label: Text('Extra Fooding')),
                  DataColumn(label: Text('Premi')),
                  DataColumn(label: Text('Premi Lebih Batas')),
                ],
                rows: dataKehadiran.isEmpty
                    ? [
                        const DataRow(
                          cells: [
                            DataCell(Text('Belum ada data')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ],
                        )
                      ]
                    : [
                        // Baris data biasa
                        ...dataKehadiran.map((item) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected == true) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SafeArea(
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.info),
                                            title: const Text('Detail'),
                                            onTap: () async {
                                              Navigator.of(context).pushNamed(
                                                '/edit-kehadiran',
                                                arguments: {
                                                  'mode':
                                                      KehadairanFormMode.edit,
                                                  'data': item,
                                                },
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete,
                                                color: Colors.red),
                                            title: const Text('Hapus'),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Konfirmasi Hapus'),
                                                  content: const Text(
                                                      'Yakin ingin menghapus data ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child:
                                                          const Text('Hapus'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await kehadiranProvider
                                                    .deleteKehadiran(
                                                        notransaksi:
                                                            item['notransaksi'],
                                                        kodeorg:
                                                            item['kodeorg'],
                                                        kodekegiatan: item[
                                                            'kodekegiatan'],
                                                        nik: item['nik']);
                                                // if (!mounted) return;
                                                setState(() {
                                                  print('send back');
                                                  kehadiranProvider
                                                      .fetchKehadiranByTransaksi(
                                                          notransaksi:
                                                              noTransaksi,
                                                          kodekegiatan:
                                                              kodekegiatanTemp,
                                                          kodeorg: kodeorgTemp,
                                                          kelompok:
                                                              luasareaproduktifTemp
                                                                  .toString(),
                                                          luasareaproduktif:
                                                              luaspokokTemp
                                                                  .toString());
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Data berhasil dihapus'),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            cells: [
                              DataCell(
                                  Text(item['namakaryawan']?.toString() ?? '')),
                              DataCell(Text(item['jhk']?.toString() ?? '')),
                              DataCell(
                                  Text(item['hasilkerja']?.toString() ?? '')),
                              DataCell(
                                Text(item['extrafooding'] != 'null'
                                    ? item['extrafooding'].toString()
                                    : '0'),
                              ),
                              DataCell(Text(item['insentif'] != ''
                                  ? item['insentif'].toString()
                                  : '0')),
                              DataCell(
                                Text(item['premilebihbasis'] != '0'
                                    ? item['premilebihbasis'].toString()
                                    : '0'),
                              ),
                            ],
                          );
                        }),

                        // Baris total
                        DataRow(
                          color: WidgetStateProperty.all(Colors.grey[300]),
                          cells: [
                            const DataCell(Text(
                              'TOTAL',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              dataKehadiran
                                  .fold<num>(0,
                                      (sum, item) => sum + (item['jhk'] ?? 0))
                                  .toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              dataKehadiran
                                  .fold<num>(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          (num.tryParse(item['hasilkerja']
                                                  .toString()) ??
                                              0))
                                  .toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              dataKehadiran
                                  .fold<num>(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          (num.tryParse(item['extrafooding']
                                                  .toString()) ??
                                              0))
                                  .toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              dataKehadiran
                                  .fold<num>(
                                      0,
                                      (sum, item) =>
                                          sum +
                                          (num.tryParse(['premi'].toString()) ??
                                              0))
                                  .toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              dataKehadiran
                                  .fold<num>(
                                      0,
                                      (sum, item) =>
                                          sum + (item['premilebihbatas'] ?? 0))
                                  .toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ],
                        ),
                      ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Foto Akhir Kegiatan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActionButton(
                      color: Colors.blue.shade900,
                      label: 'AMBIL FOTO 1',
                      onPressed: _addPicture1,
                    ),
                    const SizedBox(height: 8),
                    (_previewFile1 != null)
                        ? SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Image.file(
                              _previewFile1!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Text("Belum ada foto"),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActionButton(
                      color: Colors.blue.shade900,
                      label: 'AMBIL FOTO 2',
                      onPressed: _addPicture2,
                    ),
                    const SizedBox(height: 8),
                    (_previewFile2 != null)
                        ? SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Image.file(
                              _previewFile2!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Text("Belum ada foto"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Data Material',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: () async {
                await Navigator.of(context).pushNamed('/add-material');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 97, 147, 189),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  'TAMBAH',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                border: TableBorder.all(color: Colors.grey),
                headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                dataRowHeight: 32,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Material')),
                  DataColumn(label: Text('Satuan')),
                  DataColumn(label: Text('Kuantitas')),
                ],
                rows: dataMaterial.isEmpty
                    ? [
                        const DataRow(
                          cells: [
                            DataCell(Text('')),
                            DataCell(Text('Belum ada data')),
                            DataCell(Text('')),
                          ],
                        )
                      ]
                    : [
                        // Baris data biasa
                        ...dataMaterial.map((item) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected == true) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SafeArea(
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.delete,
                                                color: Colors.red),
                                            title: const Text('Hapus'),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Konfirmasi Hapus'),
                                                  content: const Text(
                                                      'Yakin ingin menghapus data ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child:
                                                          const Text('Hapus'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await materialProvider
                                                    .deleteMaterial(
                                                        notransaksi:
                                                            item['notransaksi'],
                                                        kodeorg:
                                                            item['kodeorg'],
                                                        kodekegiatan: item[
                                                            'kodekegiatan'],
                                                        kodebarang:
                                                            item['kodebarang']);

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Data berhasil dihapus'),
                                                  ),
                                                );

                                                materialProvider
                                                    .fetchMaterialByBkm(
                                                        notrans: noTransaksi,
                                                        kodekegiatan:
                                                            kodekegiatanTemp,
                                                        kodeorg: kodeorgTemp);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            cells: [
                              DataCell(
                                  Text(item['namabarang']?.toString() ?? '')),
                              DataCell(Text(item['satuan']?.toString() ?? '')),
                              DataCell(
                                  Text(item['kwantitas']?.toString() ?? '')),
                            ],
                          );
                        }),
                      ],
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                await _validateAndSubmit(
                    provider: prestasiProvider,
                    kodeorg: kodeorgTemp,
                    kodekegiatan: kodekegiatanTemp,
                    notrans: noTransaksi);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  'SELESAI',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  void _addPicture1() async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraCapturePage(filePrefix: 'foto_akhir_satu'),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _previewFile1 = result;
      _pathFoto1 = result.path;
      _changed1 = true;
    });
  }

  void _addPicture2() async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraCapturePage(filePrefix: 'foto_akhir_dua'),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _previewFile2 = result;
      _pathFoto2 = result.path;
      _changed2 = true; // <— penting
    });
  }

  Future<bool> _validateAndSubmit({
    required PrestasiProvider provider,
    String? kodeorg = '',
    String? kodekegiatan = '',
    String? notrans = '',
  }) async {
    final errors = <String>[];

    if (_pathFoto1 == null || !(await File(_pathFoto1!).exists())) {
      errors.add('Foto 1 tidak ditemukan.');
    }
    if (_pathFoto2 == null || !(await File(_pathFoto2!).exists())) {
      errors.add('Foto 2 tidak ditemukan.');
    }

    if (errors.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Validasi Gagal'),
          content: Text(errors.join('\n')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
      return false;
    }

    await provider.selesaiPhoto(
      image1: _pathFoto1!, // path, bukan File/base64
      image2: _pathFoto2!,
      kodekegiatan: kodekegiatan ?? '',
      kodeorg: kodeorg ?? '',
      notrans: notrans ?? '',
      context: context,
    );

    return true;
  }
}
