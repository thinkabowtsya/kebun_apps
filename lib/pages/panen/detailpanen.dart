// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/widget/camera.dart';
import 'package:flutter_application_3/pages/widget/essential.dart';
import 'package:flutter_application_3/providers/panen/detail_provider.dart';
import 'package:flutter_application_3/pages/panen/generate_qr_code.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
import 'package:flutter_application_3/utils/image_helper.dart';
import 'package:flutter_application_3/widget/camera_init.dart';
import 'package:flutter_application_3/widget/datatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DetailPanenMode {
  add,
  edit,
}

class DetailPanenPage extends StatelessWidget {
  final DetailPanenMode mode;
  final String? blok;
  final String? notransaksi;
  final String? rotasi;
  final String? nik;
  final String? notph;

  const DetailPanenPage(
      {super.key,
      this.mode = DetailPanenMode.add,
      this.notransaksi,
      this.rotasi,
      this.nik,
      this.blok,
      this.notph});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$blok'),
        backgroundColor: const Color.fromARGB(255, 87, 173, 243),
      ),
      body: DetailPanenBody(
        mode: mode,
        notransaksi: notransaksi,
        rotasi: rotasi,
        nik: nik,
        blok: blok,
        notph: notph,
      ),
    );
  }
}

class DetailPanenBody extends StatefulWidget {
  final DetailPanenMode mode;
  final String? notransaksi;
  final String? rotasi;
  final String? blok;
  final String? nik;
  final String? notph;

  const DetailPanenBody(
      {super.key,
      this.mode = DetailPanenMode.add,
      this.notransaksi,
      this.rotasi,
      this.nik,
      this.blok,
      this.notph});

  @override
  State<DetailPanenBody> createState() => _DetailPanenBodyState();
}

class _DetailPanenBodyState extends State<DetailPanenBody> {
  final TextEditingController _jjgController = TextEditingController();
  final TextEditingController _brondolanController = TextEditingController();

  String _username = '';
  CameraController? _cameraController;

  File? _watermarkedImage1;
  File? _watermarkedImage2;
  bool _isTakingPicture1 = false;
  bool _isTakingPicture2 = false;
  Position? _currentPosition;
  bool _isTakingPicture = false;
  String _selectedSesi = '';
  String? _base64Image1;
  File? _previewFile;
  File? _capturedImage;

  String? _pathFoto1;

  // File? _previewFile1;

  bool _changed1 = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _initializeMedia();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final detailProvider =
          Provider.of<DetailProvider>(context, listen: false);
      final prestasiProvider =
          Provider.of<PrestasiProvider>(context, listen: false);
      if (widget.mode == DetailPanenMode.edit && widget.notransaksi != null) {
        await detailProvider.editDataDetail(
          notransaksi: widget.notransaksi,
          nik: widget.nik,
          blok: widget.blok,
          rotasi: widget.rotasi,
        );

        final result = detailProvider.detailByTph;

        final image1 = result[0]['foto'];

        // print('result foto');
        // print(_base64Image1);

        if (_looksLikeFilePath(image1)) {
          final f = File(image1);
          if (await f.exists()) {
            setState(() {
              _pathFoto1 = image1;
              _previewFile = f;
            });
          }
        }

        // final bytes1 = await resolveImage(_capturedImage, _base64Image1);
        // if (bytes1 != null) {
        //   final file = await bytesToTempFile(bytes1);
        //   if (!mounted) return;
        //   setState(() {
        //     _previewFile = file;
        //     _capturedImage = file;
        //   });
        //   detailProvider.setImage(file);
        // }

        _jjgController.text = result[0]['jjgpanen'];
        _brondolanController.text = result[0]['brondolanpanen'];
        _selectedSesi = result[0]['rotasi'].toString();

        // prestasiProvider.setTph(widget.notph.toString());

        // context.read<DetailProvider>().listOptional(noTph: tph);
      } else {
        final detailProvider =
            Provider.of<DetailProvider>(context, listen: false);
        final panenProvider =
            Provider.of<PanenProvider>(context, listen: false);

        final prestasiProvider =
            Provider.of<PrestasiProvider>(context, listen: false);
        detailProvider.getDendaInput(
            panenProvider.notransaksi.toString(),
            prestasiProvider.selectedTph.toString(),
            prestasiProvider.selectedPemanen.toString());
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

  Future<void> _initializeMedia() async {
    _cameraController = await MediaHelper.initializeCamera(context: context);
    _currentPosition = await MediaHelper.getCurrentLocation(context);
    if (mounted) setState(() {});
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username')?.trim() ?? '';
    });
  }

  Future<void> _takePicture(int index) async {
    try {
      setState(() {
        _isTakingPicture1 = true;
      });

      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        return;
      }

      final XFile image = await _cameraController!.takePicture();
      final File watermarked = await MediaHelper.addWatermark(
        imageFile: image,
        position: _currentPosition,
      );

      if (_currentPosition != null) {
        await MediaHelper.saveLocationToPrefs(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      setState(() {
        _watermarkedImage1 = watermarked;
        _isTakingPicture1 = false;
      });
    } catch (e) {
      setState(() {
        _isTakingPicture1 = false;
      });
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sesiList = List.generate(
      6,
      (index) => {
        'value': '${index + 1}', // '1' … '6'
        'label': 'Sesi ${index + 1}', // 'Sesi 1' … 'Sesi 6'
      },
    );

// 2️⃣  State penampung pilihan
    _selectedSesi = '1'; // default otomatis Sesi 1

    return Consumer3<PanenProvider, PrestasiProvider, DetailProvider>(
      builder: (context, provider, prestasiProvider, detailProvider, _) {
        final data = context.watch<PanenProvider>().evaluasipanen;

        detailProvider.setRotasi(_selectedSesi);
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Sesi",
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
                  value: _selectedSesi,
                  items: sesiList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['value'],
                      child: Text(item['label'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    detailProvider.setRotasi(value);
                  },
                  hint: const Text("Pilih Sesi"),
                  isDense: false,
                  elevation: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Jjg",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              TextField(
                controller: _jjgController,
                textAlign: TextAlign.start,
                focusNode: FocusNode(canRequestFocus: false),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              const Text(
                "Brondolan (Kg)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              TextField(
                controller: _brondolanController,
                textAlign: TextAlign.start,
                focusNode: FocusNode(canRequestFocus: false),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              const SectionTitle('Foto Buah'),
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
              const SizedBox(height: 8),
              const SectionTitle('Mutu Buah'),
              ActionButton(
                color: const Color.fromARGB(255, 81, 119, 183),
                label: 'TAMBAH',
                onPressed: () async {
                  print('tambah');
                  await Navigator.of(context).pushNamed('/mutu-buah',
                      arguments: {'blok': widget.blok});
                },
              ),
              CustomDataTableWidget(
                data: context.watch<DetailProvider>().getDendaListByTph(
                      noTransaksi: provider.notransaksi.toString(),
                      noTph: widget.blok.toString(),
                      pemanen: prestasiProvider.selectedPemanen.toString(),
                    ),
                columns: const [
                  'deskripsi',
                  'value',
                ],
                labelMapping: const {
                  'deskripsi': 'Nama',
                  'value': 'Jumlah',
                },
                enableBottomSheet: true,
                bottomSheetActions: [
                  {
                    'label': 'Hapus',
                    'icon': Icons.delete,
                    'colors': Colors.red,
                    'onTap': (row) => doDelete(row),
                  },
                ],
              ),
              const SizedBox(height: 8),
              ActionButton(
                label: 'SIMPAN',
                onPressed: () async {
                  // ignore: unrelated_type_equality_checks
                  String? action;
                  if (widget.mode == DetailPanenMode.edit) {
                    print('ini mode edit');
                    action = 'edit';
                  }

                  final result = await _simpanEvaluasi(
                      provider,
                      prestasiProvider,
                      detailProvider,
                      _jjgController.text,
                      _brondolanController.text,
                      action,
                      widget.blok);
                  await Navigator.of(context).pushNamed(
                    '/print-qr',
                    arguments: {
                      'noTransaksi': provider.notransaksi,
                      'blok': widget.blok,
                      'rotasi': '1',
                      'nik': prestasiProvider.selectedPemanen,
                    },
                  );

                  context.read<PrestasiProvider>().loadDataprestasipanen(
                      notransaksi: provider.notransaksi,
                      pemanen: prestasiProvider.selectedPemanen);
                  Navigator.pop(context, true);
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  void _addPicture() async {
    final provider = context.read<DetailProvider>();
    final File? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const CameraCapturePage(filePrefix: 'foto_awal')),
    );

    print('preview foto');
    print(_previewFile);
    if (!mounted || result == null) return;

    // if (result != null) {
    setState(() {
      _previewFile = result;
      // _capturedImage = result;
      _pathFoto1 = result.path;
      _changed1 = true;
    });

    provider.setImage(_pathFoto1);
    // }
  }

  void doDelete(row) {
    final detailProvider = Provider.of<DetailProvider>(context, listen: false);
    final panenProvider = Provider.of<PanenProvider>(context, listen: false);
    final prestasiProvider =
        Provider.of<PrestasiProvider>(context, listen: false);

    detailProvider.resetDendaValueByKode(
        noTransaksi: panenProvider.notransaksi.toString(),
        noTph: widget.blok.toString(),
        pemanen: prestasiProvider.selectedPemanen.toString(),
        kode: row['kode']);
  }

  // Future<Uint8List?> resolveImage(File? file, String? base64) async {
  //   if (file != null) return await file.readAsBytes();
  //   if (isValidBase64(base64)) return base64Decode(base64!);
  //   return null;
  // }

  Future<void> _simpanEvaluasi(PanenProvider panen, PrestasiProvider prestasi,
      DetailProvider detail, jjgpanen, brondolan, action, selectedTph) async {
    try {
      final errorsFoto = <String>[];

      final errors = await detail.addEvaluasi(
          notransaksi: panen.notransaksi,
          pemanen: prestasi.selectedPemanen,
          tanggal: panen.tanggal,
          notph: selectedTph);

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
        // if (_watermarkedImage1 == null) {
        //   errorsFoto.add(' Silahkan foto lokasi buah');

        //   return;
        // }

        final bytes1 = await resolveImage(_watermarkedImage1, _base64Image1);

        final errors = await detail.execEvaluasi(
            notransaksi: panen.notransaksi!,
            pemanen: prestasi.selectedPemanen,
            blok: selectedTph,
            rotasi: detail.selectedRotasi,
            jjgpanen: jjgpanen,
            brondolanpanen: brondolan,
            // foto: bytes1!,
            action: action,
            notph: selectedTph);

        if (errorsFoto.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('silahkan masukkan foto lokasi buah')),
          );

          return;
        } else if (errors.isNotEmpty) {
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
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan')),
      );
    }
  }

  bool isValidBase64(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return false;
    try {
      base64.decode(base64Str);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildCameraPreviewWithButton() {
    final bool isTakingPhoto = _isTakingPicture1;
    final File? photo = _watermarkedImage1;
    final String? base64Photos = _base64Image1;

    // decode dulu
    Uint8List? base64ImageBytes;
    if (isValidBase64(base64Photos)) {
      base64ImageBytes = base64.decode(base64Photos!);
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // PRIORITAS: photo -> base64 -> kamera -> loading
          if (photo != null)
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: _cameraController?.value.aspectRatio ?? 3 / 4,
                  child: Image.file(
                    photo,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                // ... overlay info
              ],
            )
          else if (base64ImageBytes != null)
            AspectRatio(
              aspectRatio: _cameraController?.value.aspectRatio ?? 3 / 4,
              child: Image.memory(
                base64ImageBytes,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          else if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Tombol ambil foto
          if (photo == null && base64ImageBytes == null)
            Positioned(
              bottom: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color.fromARGB(255, 34, 85, 126),
                onPressed: isTakingPhoto ? null : () => _takePicture(0),
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

          // Tombol hapus foto
          if (photo != null || base64ImageBytes != null)
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () =>
                    _clearPhoto(0), // Ini otomatis hapus dua sumber foto
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
      _watermarkedImage1 = null;
      _base64Image1 = null;
    });
  }
}
