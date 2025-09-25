import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/camera.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/widget/searchable_selector.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class AddPrestasiPage extends StatelessWidget {
  AddPrestasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Baru'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: AddPrestasiBody(),
    );
  }
}

class AddPrestasiBody extends StatefulWidget {
  AddPrestasiBody({super.key});

  @override
  State<AddPrestasiBody> createState() => _AddPrestasiBodyState();
}

class _AddPrestasiBodyState extends State<AddPrestasiBody> {
  final TextEditingController _noTransaksiController = TextEditingController();
  CameraController? _cameraController;

  File? _watermarkedImage1;
  File? _watermarkedImage2;
  bool _isTakingPicture1 = false;
  bool _isTakingPicture2 = false;
  Position? _currentPosition;
  bool _isTakingPicture = false;

  String? selectedAfdeling;
  String? selectedBlok;
  String? selectedKegiatan;

  File? _previewFile1;
  File? _capturedImage1;

  File? _previewFile2;
  File? _capturedImage2;

  String? _pathFoto1;
  String? _pathFoto2;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<PrestasiProvider>(context, listen: false);
    Future.microtask(() {
      provider.fetchAfdeling(); // dapetin list Afdeling
    });

    // String noBKM = widget.noBKM;
    // print('NoBKM dari halaman sebelumnya: ${widget.noBKM}');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      provider.fetchAfdeling();
    });
  }

  @override
  void dispose() {
    _noTransaksiController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrestasiProvider>(builder: (context, provider, child) {
      final provider = Provider.of<PrestasiProvider>(context, listen: false);

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                value: selectedAfdeling,
                items: _buildAfdelingItems(provider.afdeling),
                onChanged: (value) {
                  // provider.setSelectedAfdelingValue(value!);
                  // provider.fetchBlok(val: value);
                  setState(() {
                    selectedAfdeling = value;
                    selectedBlok = null;
                    selectedKegiatan = null;
                  });
                  provider.fetchBlok(val: value!);
                },
                hint: const Text("Pilih Afdeling"),
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
            SearchableSelector(
              data: provider.blok.map((item) {
                return {
                  'id': item['kodeblok'].toString(),
                  'name': "${item['kodeblok']} ",
                  'subtitle': "${item['tahuntanam']}",
                };
              }).toList(),
              labelText: 'Pilih Blok',
              onSelected: (selectedId) async {
                setState(() {
                  selectedBlok = selectedId;
                  selectedKegiatan = null;
                });
                provider.changeKegiatanByBlok(val: selectedId!);
              },
            ),
            // DropdownButtonHideUnderline(
            //   child: DropdownButton(
            //     isExpanded: true,
            //     value: selectedBlok,
            //     items: _buildBlokItems(provider.blok),
            //     onChanged: (value) {
            //       setState(() {
            //         selectedBlok = value;
            //         selectedKegiatan = null;
            //       });
            //       provider.changeKegiatanByBlok(val: value!);
            //     },
            //     hint: const Text("Pilih Blok"),
            //   ),
            // ),
            const SizedBox(height: 8),
            const Text(
              "Kegiatan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            SearchableSelector(
              data: provider.kegiatan.map((item) {
                return {
                  'id': item['kodekegiatan'].toString(),
                  'name': "${item['namakegiatan']}",
                  'subtitle': "${item['kodekegiatan']} | ${item['kelompok']}",
                };
              }).toList(),
              labelText: 'Pilih Kegiatan',
              onSelected: (selectedId) async {
                setState(() {
                  selectedKegiatan = selectedId;
                });
                // provider.changeKegiatanByBlok(val: selectedId!);
              },
            ),
            // DropdownButtonHideUnderline(
            //   child: DropdownButton(
            //     isExpanded: true,
            //     value: selectedKegiatan,
            //     items: _buildKegiatanItems(provider.kegiatan),
            //     onChanged: (value) {
            //       // provider.setSelectedKegiatanValue(value!);
            //       setState(() {
            //         selectedKegiatan = value;
            //       });
            //     },
            //     hint: const Text("Pilih Kegiatan"),
            //   ),
            // ),
            const SizedBox(height: 20),
            const Text(
              "Foto Mulai Kegiatan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
            TextButton(
              onPressed: () async {
                final bkmProvider =
                    Provider.of<BkmProvider>(context, listen: false);

                final isValid = await _validateAndSubmit(
                    provider: provider,
                    selectedBlok: selectedBlok,
                    selectedAfdeling: selectedAfdeling,
                    selectedKegiatan: selectedKegiatan,
                    noBkm: bkmProvider.notransaksi);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  'SIMPAN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  // void _addPicture1() async {
  //   final provider = context.read<PrestasiProvider>();
  //   final File? result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const CameraCapturePage()),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       _previewFile1 = result;
  //       _capturedImage1 = result;
  //     });
  //     // provider.setImage(result);
  //   }
  // }

  Future<void> _addPicture1() async {
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraCapturePage(filePrefix: 'foto_awal'),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _previewFile1 = result; // untuk preview
      _pathFoto1 = result.path; // inilah yang disimpan ke DB kolom foto kamu
    });

    // contoh kalau mau langsung store ke Provider/DB:
    // context.read<PrestasiProvider>().setFotoAwalPath(_pathFoto1!);
  }

  void _addPicture2() async {
    final provider = context.read<PrestasiProvider>();
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const CameraCapturePage(filePrefix: 'foto_akhir')),
    );
    if (result != null) {
      setState(() {
        _previewFile2 = result;
        // _capturedImage2 = result;
        _pathFoto2 = result.path;
      });
      // provider.setImage(result);
    }

    print(_pathFoto2);
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

  Future<bool> _validateAndSubmit({
    required PrestasiProvider provider,
    String? selectedBlok = '',
    String? selectedAfdeling = '',
    String? selectedKegiatan = '',
    String? noBkm,
  }) async {
    final errors = <String>[];

    if (_pathFoto1 == null) errors.add('Gambar 1 wajib diisi');
    if (_pathFoto1 == null) errors.add('Gambar 2 wajib diisi');
    if (selectedBlok == null || selectedBlok.isEmpty)
      errors.add('Blok wajib diisi');
    if (selectedAfdeling == null || selectedAfdeling.isEmpty)
      errors.add('Afdeling wajib diisi');
    if (selectedKegiatan == null || selectedKegiatan.isEmpty)
      errors.add('Kegiatan wajib diisi');

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
      return false;
    }

    provider.savePrestasi(
      // image1: _capturedImage1!,
      // image2: _capturedImage2!,
      image1: _pathFoto1!,
      image2: _pathFoto2!,
      noBKM: noBkm!,
      kegiatan: selectedKegiatan!,
      blok: selectedBlok!,
      context: context,
    );

    return true;
  }
}
