// image_cell.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

typedef CellBuilder = DataCell Function(
    Map<String, dynamic> row, BuildContext ctx);

bool _isLikelyBase64(String s) {
  var v = s.trim();
  final i = v.indexOf('base64,');
  if (i != -1) v = v.substring(i + 'base64,'.length);
  v = v.replaceAll(RegExp(r'\s'), '');
  final re = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
  return v.isNotEmpty && v.length % 4 == 0 && re.hasMatch(v);
}

Uint8List? _tryDecodeBase64(String s) {
  try {
    var v = s.trim();
    final i = v.indexOf('base64,');
    if (i != -1) v = v.substring(i + 'base64,'.length);
    v = v.replaceAll(RegExp(r'\s'), '');
    return base64Decode(v);
  } catch (_) {
    return null;
  }
}

bool _isLikelyFilePath(String s) =>
    s.startsWith('/') || s.startsWith('file:/') || s.startsWith(r'C:\');

bool _isLikelyHttp(String s) =>
    s.startsWith('http://') || s.startsWith('https://');

/// Builder kolom foto yang fleksibel: base64, file path, atau URL
CellBuilder buildPhotoCellAny(
  String key, {
  double size = 72,
  BoxFit fit = BoxFit.cover,
}) {
  return (row, ctx) {
    final val = row[key];
    final dpr = MediaQuery.of(ctx).devicePixelRatio;
    final cacheW = (size * dpr).round();

    Widget thumb;
    Widget? full; // untuk preview fullscreen

    if (val is Uint8List && val.isNotEmpty) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(val,
            width: size, height: size, fit: fit, gaplessPlayback: true),
      );
      full = Image.memory(val, fit: BoxFit.contain, gaplessPlayback: true);
    } else if (val is String && val.trim().isNotEmpty) {
      final s = val.trim();

      if (_isLikelyBase64(s)) {
        final bytes = _tryDecodeBase64(s);
        if (bytes != null && bytes.isNotEmpty) {
          thumb = ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(bytes,
                width: size, height: size, fit: fit, gaplessPlayback: true),
          );
          full =
              Image.memory(bytes, fit: BoxFit.contain, gaplessPlayback: true);
        } else {
          thumb = const Icon(Icons.image_not_supported, size: 28);
        }
      } else if (_isLikelyFilePath(s)) {
        final file =
            s.startsWith('file:') ? File(Uri.parse(s).toFilePath()) : File(s);
        thumb = ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: fit,
            gaplessPlayback: true,
            cacheWidth: cacheW,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 28),
          ),
        );
        full = Image.file(file, fit: BoxFit.contain, gaplessPlayback: true);
      } else if (_isLikelyHttp(s)) {
        thumb = ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            s,
            width: size,
            height: size,
            fit: fit,
            cacheWidth: cacheW,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 28),
          ),
        );
        full = Image.network(s, fit: BoxFit.contain);
      } else {
        // string lain yang gak dikenali
        thumb = const Icon(Icons.image_not_supported, size: 28);
      }
    } else {
      thumb = const Icon(Icons.image_not_supported, size: 28);
    }

    return DataCell(
      GestureDetector(
        onTap: full == null
            ? null
            : () {
                showDialog(
                  context: ctx,
                  builder: (_) => Dialog(
                    insetPadding: const EdgeInsets.all(12),
                    child: InteractiveViewer(child: full!),
                  ),
                );
              },
        child: SizedBox(width: size, height: size, child: Center(child: thumb)),
      ),
    );
  };
}
