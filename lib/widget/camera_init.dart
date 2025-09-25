import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaHelper {
  /// Inisialisasi kamera dan kembalikan `CameraController`
  static Future<CameraController?> initializeCamera({
    required BuildContext context,
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras available')),
        );
        return null;
      }

      final controller = CameraController(cameras[0], resolution);
      await controller.initialize();
      return controller;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initialize camera')),
      );
      return null;
    }
  }

  /// Ambil lokasi saat ini jika permission diberikan
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied')),
        );
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location')),
      );
      return null;
    }
  }

  /// Tambahkan watermark ke foto
  static Future<File> addWatermark({
    required XFile imageFile,
    required Position? position,
  }) async {
    try {
      final originalImageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(originalImageBytes)!;

      final now = DateTime.now();
      final watermarkText = '${now.toLocal().toString().split('.')[0]} | '
          'Lat: ${position?.latitude.toStringAsFixed(4) ?? 'N/A'}, '
          'Long: ${position?.longitude.toStringAsFixed(4) ?? 'N/A'}';

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

      return File(watermarkedPath)
        ..writeAsBytesSync(img.encodeJpg(originalImage));
    } catch (e) {
      debugPrint('Error adding watermark: $e');
      rethrow;
    }
  }

  static Future<void> saveLocationToPrefs(
      double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_latitude', latitude);
    await prefs.setDouble('last_longitude', longitude);
    print('Lokasi disimpan: $latitude, $longitude');
  }
}
