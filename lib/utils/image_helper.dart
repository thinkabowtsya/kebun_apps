import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

String _cleanBase64(String s) {
  s = s.trim();
  final i = s.indexOf(',');
  if (i != -1 && s.substring(0, i).contains('base64')) {
    s = s.substring(i + 1); // buang "data:image/...;base64,"
  }
  s = s.replaceAll(RegExp(r'\s+'), ''); // buang spasi/newline
  final pad = s.length % 4; // betulkan padding
  if (pad > 0) s = s.padRight(s.length + (4 - pad), '=');
  return s;
}

bool isValidBase64(String? base64Str) {
  if (base64Str == null || base64Str.isEmpty) return false;
  try {
    base64.decode(_cleanBase64(base64Str));
    return true;
  } catch (_) {
    return false;
  }
}

Future<Uint8List?> resolveImage(File? file, String? base64Str) async {
  if (file != null) return await file.readAsBytes();
  if (isValidBase64(base64Str)) return base64Decode(_cleanBase64(base64Str!));
  return null;
}

String _guessExt(Uint8List b) {
  if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF)
    return '.jpg'; // JPEG
  if (b.length >= 8 &&
      b[0] == 0x89 &&
      b[1] == 0x50 &&
      b[2] == 0x4E &&
      b[3] == 0x47) return '.png'; // PNG
  if (b.length >= 12 &&
      b[0] == 0x52 &&
      b[1] == 0x49 &&
      b[2] == 0x46 &&
      b[3] == 0x46) return '.webp'; // WEBP (RIFF)
  return '.bin';
}

Future<File> bytesToTempFile(Uint8List bytes, {String prefix = 'spb_'}) async {
  final dir = await getTemporaryDirectory();
  final ext = _guessExt(bytes); // buat JPEG kamu, ini akan ".jpg"
  final file =
      File('${dir.path}/$prefix${DateTime.now().millisecondsSinceEpoch}$ext');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}
