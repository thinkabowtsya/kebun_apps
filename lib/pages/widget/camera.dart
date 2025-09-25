// camera_capture_page.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/photo_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraCapturePage extends StatefulWidget {
  final void Function(File file, String path)? onPictureTaken;
  final String filePrefix; // biar beda nama per konteks (awal/akhir)
  const CameraCapturePage(
      {super.key, this.onPictureTaken, this.filePrefix = 'foto'});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  Position? _pos;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cams = await availableCameras();
    _controller =
        CameraController(cams.first, ResolutionPreset.max, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
    _pos = await _getLocationSafe();
  }

  Future<Position?> _getLocationSafe() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied)
      perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) return null;
    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> _shot() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      final x = await _controller!.takePicture();
      final lat = _pos?.latitude.toStringAsFixed(6);
      final lon = _pos?.longitude.toStringAsFixed(6);
      final wm = await PhotoHelper.watermarkAndSave(
        rawFile: File(x.path),
        latText: lat,
        lonText: lon,
        filePrefix: widget.filePrefix,
      );

      // simpan koordinat terakhir (opsional)
      final sp = await SharedPreferences.getInstance();
      if (lat != null) await sp.setDouble('last_latitude', _pos!.latitude);
      if (lon != null) await sp.setDouble('last_longitude', _pos!.longitude);

      widget.onPictureTaken?.call(wm, wm.path);
      if (mounted) Navigator.pop(context, wm);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal ambil foto: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        SizedBox.expand(child: CameraPreview(_controller!)),
        Positioned(
          top: 40,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4)),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: _busy ? null : _shot,
                child: Center(
                  child: _busy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(_pos == null ? "Ambil Foto (GPS off)" : "Ambil Foto",
                style: const TextStyle(color: Colors.white)),
          ]),
        ),
      ]),
    );
  }
}
