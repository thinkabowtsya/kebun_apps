import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/addData.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();

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
        await PrestasiProvider.saveLocationToPrefs(
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
            DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                value: selectedBlok,
                items: _buildBlokItems(provider.blok),
                onChanged: (value) {
                  // provider.setSelectedBlokValue(value!);
                  // // print(value);
                  // provider.changeKegiatanByBlok(val: value);
                  setState(() {
                    selectedBlok = value;
                    selectedKegiatan = null;
                  });
                  provider.changeKegiatanByBlok(val: value!);
                },
                hint: const Text("Pilih Blok"),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Kegiatan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                value: selectedKegiatan,
                items: _buildKegiatanItems(provider.kegiatan),
                onChanged: (value) {
                  // provider.setSelectedKegiatanValue(value!);
                  setState(() {
                    selectedKegiatan = value;
                  });
                },
                hint: const Text("Pilih Kegiatan"),
              ),
            ),
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
            TextButton(
              onPressed: () async {
                final bkmProvider =
                    Provider.of<BkmProvider>(context, listen: false);

                // pakai selected* di sini
                // if (selectedAfdeling != null &&
                //     selectedBlok != null &&
                //     selectedKegiatan != null) {
                final isValid = await _validateAndSubmit(
                    provider: provider,
                    selectedBlok: selectedBlok,
                    selectedAfdeling: selectedAfdeling,
                    selectedKegiatan: selectedKegiatan,
                    noBkm: bkmProvider.notransaksi);

                // // provider.blok = [];
                // if (isValid) {
                //   return true;
                // }
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

  Widget _buildCameraPreviewWithButton(int index) {
    // Jika ini foto 2 dan foto 1 belum ada
    if (index == 1 && _watermarkedImage1 == null) {
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

    final File? photo = index == 0 ? _watermarkedImage1 : _watermarkedImage2;
    final bool isTakingPhoto =
        index == 0 ? _isTakingPicture1 : _isTakingPicture2;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Camera Preview atau Foto yang sudah diambil
          if (photo != null)
            Stack(
              children: [
                Image.file(
                  photo,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                      maxLines: 3,
                    ),
                  ),
                ),
              ],
            )
          else
            (_cameraController != null &&
                    _cameraController!.value.isInitialized)
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 500,
                      height: 600,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),

          // Tombol ambil foto di tengah (hanya muncul jika belum ada foto)
          if (photo == null && (index == 0 || _watermarkedImage1 != null))
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

          // Tombol clear (X) di pojok kanan atas (hanya muncul jika sudah ada foto)
          if (photo != null)
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
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

        _watermarkedImage2 = null;
      } else {
        _watermarkedImage2 = null;
      }
    });
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _validateAndSubmit({
    required PrestasiProvider provider,
    String? selectedBlok = '',
    String? selectedAfdeling = '',
    String? selectedKegiatan = '',
    String? noBkm,
  }) async {
    final errors = <String>[];

    if (_watermarkedImage1 == null) errors.add('Gambar 1 wajib diisi');
    if (_watermarkedImage2 == null) errors.add('Gambar 2 wajib diisi');
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

    // validasi lolos, simpan data
    provider.savePrestasi(
      image1: _watermarkedImage1!,
      image2: _watermarkedImage2!,
      noBKM: noBkm!,
      kegiatan: selectedKegiatan!,
      blok: selectedBlok!,
      context: context,
    );

    return true;
  }
}
