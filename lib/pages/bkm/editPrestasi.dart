import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/addKehadiran.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/kehadiran_provider.dart';
import 'package:flutter_application_3/providers/bkm/material_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
import 'package:flutter_application_3/services/FormMode.dart';
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
        provider.fetchKehadiranByTransaksi(
            notransaksi: noTransaksi,
            kodekegiatan: kodekegiatanTemp,
            kodeorg: kodeorgTemp,
            kelompok: luasareaproduktifTemp.toString(),
            luasareaproduktif: luaspokokTemp.toString());
      });
      provider.setShouldRefresh(false);
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

  void _loadDataFromDB(String? kodekegiatan, String? kodeorg) async {
    final provider = Provider.of<PrestasiProvider>(context, listen: false);

    final result = await provider.fetchPhotoAkhir(
        kodekegiatan.toString(), kodeorg.toString());

    if (result.isNotEmpty) {
      setState(() {
        _base64Image1 = result.first['jumlahhasilkerja'];
        _base64Image2 = result.first['fotoend2'];
      });
    }
  }

  Future<void> _takePicture(int index) async {
    try {
      setState(() {
        if (index == 0) {
          _isTakingPicture1 = true;
        } else {
          _isTakingPicture2 = true;
        }
      });

      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        return;
      }

      final XFile image = await _cameraController!.takePicture();
      final File watermarked = await _addWatermark(image);

      if (_currentPosition != null) {
        await DataProvider.saveLocationToPrefs(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      setState(() {
        if (index == 0) {
          _watermarkedImage1 = watermarked;
          _isTakingPicture1 = false;
        } else {
          _watermarkedImage2 = watermarked;
          _isTakingPicture2 = false;
        }
      });
    } catch (e) {
      setState(() {
        if (index == 0) {
          _isTakingPicture1 = false;
        } else {
          _isTakingPicture2 = false;
        }
      });
      debugPrint('Error taking picture: $e');
    }
  }

  Future<File> _addWatermark(XFile imageFile) async {
    try {
      final originalImageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(originalImageBytes)!;

      final DateTime now = DateTime.now();
      final watermarkText = ' ${now.toLocal().toString().split('.')[0]} | '
          'Lat: ${_currentPosition?.latitude.toStringAsFixed(4) ?? 'N/A'}, '
          'Long: ${_currentPosition?.longitude.toStringAsFixed(4) ?? 'N/A'}';

      const fontSize = 24.0;
      const padding = 10.0;

      img.drawString(
        originalImage,
        watermarkText,
        font: img.arial24,
        x: 10,
        y: originalImage.height - 40,
        color: img.ColorRgb8(255, 0, 0),
      );

      final directory = await getTemporaryDirectory();
      final watermarkedPath =
          '${directory.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final watermarkedFile = File(watermarkedPath)
        ..writeAsBytesSync(img.encodeJpg(originalImage));

      return watermarkedFile;
    } catch (e) {
      debugPrint('Error adding watermark: $e');
      rethrow;
    }
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
                        await Navigator.of(context).pushNamed('/add-kehadiran');
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

                                                await kehadiranProvider
                                                    .fetchKehadiranByTransaksi(
                                                        notransaksi:
                                                            item['notransaksi'],
                                                        kodekegiatan: item[
                                                            'kodekegiatan'],
                                                        kodeorg:
                                                            item['kodeorg'],
                                                        kelompok:
                                                            item['kelompok'],
                                                        luasareaproduktif: item[
                                                                'luasareaproduktif']
                                                            .toString());

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildCameraPreviewWithButton(0),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _buildCameraPreviewWithButton(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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

  bool isValidBase64(String? value) {
    if (value == null || value.isEmpty) return false;
    final regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return value.length % 4 == 0 && regex.hasMatch(value);
  }

  Widget _buildCameraPreviewWithButton(int index) {
    final File? photo = index == 0 ? _watermarkedImage1 : _watermarkedImage2;
    final bool isTakingPhoto =
        index == 0 ? _isTakingPicture1 : _isTakingPicture2;
    final String? base64Photos = index == 0 ? _base64Image1 : _base64Image2;

    // Jika ini foto ke-2 tapi foto ke-1 belum ada
    if (index == 1 && _watermarkedImage1 == null && _base64Image1 == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Ambil Foto 1 terlebih dahulu',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    ImageProvider? imageProvider;
    if (photo != null) {
      imageProvider = FileImage(photo);
    } else if (isValidBase64(base64Photos)) {
      try {
        imageProvider = MemoryImage(base64Decode(base64Photos!));
      } catch (e) {
        debugPrint("Gagal decode base64: $e");
      }
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (imageProvider != null)
            Stack(
              children: [
                Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      _currentPosition != null
                          ? 'Foto ${index + 1}: ${DateTime.now().toLocal().toString().split('.')[0]}\n'
                              'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}\n'
                              'Long: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                          : 'Foto ${index + 1}: ${DateTime.now().toLocal().toString().split('.')[0]}',
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                      maxLines: 3,
                    ),
                  ),
                ),
              ],
            )
          else if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: 500,
                height: 600,
                child: CameraPreview(_cameraController!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // ✅ Tombol kamera hanya muncul jika belum ada file atau base64 valid
          if (photo == null &&
              !isValidBase64(base64Photos) &&
              (index == 0 || _watermarkedImage1 != null))
            Positioned(
              bottom: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color.fromARGB(255, 34, 85, 126),
                onPressed: isTakingPhoto ? null : () => _takePicture(index),
                child: isTakingPhoto
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),

          // ✅ Tombol hapus muncul jika ada file atau base64 valid
          if (photo != null || isValidBase64(base64Photos))
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => _clearPhoto(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _clearPhoto(int index) {
    setState(() {
      if (index == 0) {
        _watermarkedImage1 = null;
        _base64Image1 = null;
        _watermarkedImage2 = null; // reset foto 2 jika foto 1 dihapus
        _base64Image2 = null;
      } else {
        _watermarkedImage2 = null;
        _base64Image2 = null;
      }
    });
  }

  Future<bool> _validateAndSubmit({
    required PrestasiProvider provider,
    String? kodeorg = '',
    String? kodekegiatan = '',
    String? notrans = '',
  }) async {
    final errors = <String>[];

    // Ambil gambar dari File atau base64
    final bytes1 = await resolveImage(_watermarkedImage1, _base64Image1);
    final bytes2 = await resolveImage(_watermarkedImage2, _base64Image2);

    // Validasi
    if (bytes1 == null) errors.add('Gambar 1 wajib diisi');
    if (bytes2 == null) errors.add('Gambar 2 wajib diisi');

    if (errors.isNotEmpty) {
      await showDialog(
        context: context,
        useRootNavigator: false, // penting kalau pakai nested Navigator
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
      return false;
    }

    // Jika lolos validasi, submit ke provider
    await provider.selesaiPhoto(
      image1: bytes1!,
      image2: bytes2!,
      kodekegiatan: kodekegiatan ?? '',
      kodeorg: kodeorg ?? '',
      notrans: notrans ?? '',
      context: context,
    );

    return true;
  }

  Future<Uint8List?> resolveImage(File? file, String? base64) async {
    if (file != null) return await file.readAsBytes();
    if (isValidBase64(base64)) return base64Decode(base64!);
    return null;
  }

  List<DropdownMenuItem<String>> _buildAfdelingItems(
      List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DropdownMenuItem(
        value: item['kodeorganisasi'].toString(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['namaorganisasi']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildBlokItems(
      List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DropdownMenuItem(
        value: item['kodeblok'].toString(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['kodeblok']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${item['tahuntanam']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildKegiatanItems(
      List<Map<String, dynamic>> data) {
    return data.map((item) {
      return DropdownMenuItem(
        value: item['kodekegiatan'].toString(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item['namakegiatan']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${item['kodekegiatan']} | ${item['kelompok']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
