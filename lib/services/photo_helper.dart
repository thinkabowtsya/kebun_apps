// photo_helper.dart
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PhotoHelper {
  /// Tambah watermark (tanggal + lat/lon), kompres, simpan ke app dir.
  static Future<File> watermarkAndSave({
    required File rawFile,
    String? latText,
    String? lonText,
    String filePrefix = 'foto',
  }) async {
    // decode
    final original = img.decodeImage(await rawFile.readAsBytes());
    if (original == null) throw Exception('Gagal decode gambar');

    // teks watermark
    final now = DateTime.now();
    const hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    final h = hari[now.weekday % 7];
    final tgl = '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final baris1 = '$h, $tgl';
    final baris2 =
        'Latitude: ${latText ?? "N/A"}   Longitude: ${lonText ?? "N/A"}';

    // area footer
    final font = img.arial24;
    final pad = 10;
    final footerH = font.lineHeight * 2 + pad * 3;
    img.fillRect(original,
        x1: 0,
        y1: original.height - footerH,
        x2: original.width,
        y2: original.height,
        color: img.ColorRgb8(0, 0, 0));
    img.drawString(original, baris1,
        font: font,
        x: pad,
        y: original.height - footerH + pad,
        color: img.ColorRgb8(255, 255, 0));
    img.drawString(original, baris2,
        font: font,
        x: pad,
        y: original.height - font.lineHeight - pad,
        color: img.ColorRgb8(255, 255, 0));

    // simpan sementara (jpg)
    final tmp = File(
        '${(await getTemporaryDirectory()).path}/wm_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tmp.writeAsBytes(img.encodeJpg(original, quality: 92));

    // kompres final (ukuran aman)
    final docs = await getApplicationDocumentsDirectory();
    final outPath =
        '${docs.path}/$filePrefix${DateTime.now().millisecondsSinceEpoch}.jpg';
    final comp = await FlutterImageCompress.compressAndGetFile(
        tmp.path, outPath,
        quality: 80, minWidth: 1280, minHeight: 1280);
    return File(comp?.path ?? outPath);
  }

  /// Encode file → base64 + url-encode (untuk dikirim ke server via param/string)
  static Future<String> encodeFileForParam(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return '';
    final f = File(filePath);
    if (!await f.exists()) return '';
    final data = await f.readAsBytes();
    // kalau mau ekstra kecil, bisa compress lagi di sini
    final b64 = base64Encode(data);
    return Uri.encodeComponent(b64);
  }
}
