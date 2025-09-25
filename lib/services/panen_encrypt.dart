// lib/services/panen_encrypt.dart
// Uses HashkitDart for encode/decode and exposes the same helper functions as the JS version.
// Save as lib/services/panen_encrypt.dart
// NOTE: adjust import if you place files in different folders.

import 'package:flutter/foundation.dart';
import 'hashkit.dart'; // jika beda path, ganti ke 'package:your_pkg/services/hashkit.dart'

class PanenEncrypt {
  static final HashkitDart hashkit = HashkitDart();

  static String _lpad(String s, int length, String padChar) {
    if (s.length >= length) return s;
    return padChar * (length - s.length) + s;
  }

  // ---------- encryptNumber (safe) ----------
  static String encryptNumber(dynamic numb) {
    if (numb == null) return '';
    final s = numb.toString();
    final sTrim = s.trim();
    if (sTrim.isEmpty) {
      debugPrint('[encryptNumber] in=<$s> out= (empty input, return empty)');
      return '';
    }

    if (sTrim.contains('.')) {
      final parts = sTrim.split('.');
      final left = parts[0].trim();
      final right = parts.length > 1 ? parts[1].trim() : '';
      final enc0 = left.isEmpty ? '' : hashkit.encode(left);
      final enc1 = right.isEmpty ? '' : hashkit.encode(right);
      final out = (enc1.isEmpty) ? enc0 : '$enc0.$enc1';
      debugPrint('[encryptNumber] in=$s out=$out');
      return out;
    } else {
      // left part only
      try {
        final out = hashkit.encode(sTrim);
        debugPrint('[encryptNumber] in=$s out=$out');
        return out;
      } catch (e) {
        debugPrint('[encryptNumber] encode error for "$s": $e');
        return sTrim;
      }
    }
  }

  // ---------- decryptNumber ----------
  static String decryptNumber(String str, [int? zeroPad]) {
    if (str.isEmpty) return str;
    if (str.contains('.')) {
      final parts = str.split('.');
      final dec0 = hashkit.decode(parts[0]).toString();
      final dec1 = hashkit.decode(parts[1]).toString();
      var combined = dec0 + '.' + dec1;
      if (zeroPad == null || zeroPad == 0) {
        debugPrint('[decryptNumber] in=$str out=$combined');
        return combined;
      }
      final out = _lpad(combined, zeroPad, '0');
      debugPrint('[decryptNumber] in=$str out=$out (padded)');
      return out;
    } else {
      final dec = hashkit.decode(str).toString();
      if (zeroPad == null || zeroPad == 0) {
        debugPrint('[decryptNumber] in=$str out=$dec');
        return dec;
      }
      final out = _lpad(dec, zeroPad, '0');
      debugPrint('[decryptNumber] in=$str out=$out (padded)');
      return out;
    }
  }

  // ---------- encryptNumberZeroFirst ----------
  static String encryptNumberZeroFirst(String? numb) {
    if (numb == null) return '';
    final s = numb;
    if (s.isEmpty) return '';
    int zeroCount = 0;
    String remaining = '';
    bool seenNonZero = false;
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (!seenNonZero && ch == '0') {
        zeroCount++;
      } else {
        seenNonZero = true;
        remaining += ch;
      }
    }
    String zText = '';
    if (zeroCount > 0) zText = '$zeroCount#';
    if (remaining.isNotEmpty) {
      final encRem = encryptNumber(remaining);
      final out = zText + encRem;
      debugPrint('[encryptNumberZeroFirst] in=$s out=$out');
      return out;
    } else {
      debugPrint(
          '[encryptNumberZeroFirst] in=$s out=$s (only zeros, returned raw)');
      return s;
    }
  }

  // ---------- decryptNumberZeroFirst ----------
  static String decryptNumberZeroFirst(String numb) {
    if (numb.isEmpty) return '';
    final parts = numb.split('#');
    if (parts.length > 1) {
      final numbStr = parts[1];
      final nemberLast = decryptNumber(numbStr);
      final zeroPad = int.parse(parts[0]) + nemberLast.length;
      final result = decryptNumber(numbStr, zeroPad);
      debugPrint(
          '[decryptNumberZeroFirst] in=$numb out=$result (zeroPad=$zeroPad)');
      return result;
    } else {
      final out = decryptNumber(parts[0]);
      debugPrint('[decryptNumberZeroFirst] in=$numb out=$out');
      return out;
    }
  }

  // ---------- dateEncrtypt / dateDecrtypt ----------
  static String dateEncrtypt(String? dateSystem) {
    if (dateSystem == null || dateSystem.isEmpty) return '';
    try {
      final d = DateTime.parse(dateSystem);
      final Yr = d.year.toString();
      final mn = _lpad(d.month.toString(), 2, '0');
      final day = _lpad(d.day.toString(), 2, '0');
      final dateNmb = Yr + mn + day;
      final validate = int.tryParse(dateNmb);
      if (validate != null) {
        // pass numeric string (Hashkit expects numeric)
        final out = hashkit.encode(validate.toString());
        debugPrint('[dateEncrtypt] in=$dateSystem dateNmb=$dateNmb out=$out');
        return out;
      }
    } catch (e) {
      debugPrint('[dateEncrtypt] parse error for $dateSystem -> $e');
    }
    return dateSystem ?? '';
  }

  static String dateDecrtypt(String dateEncrypt) {
    if (dateEncrypt.isEmpty) return dateEncrypt;
    if (dateEncrypt.contains('-')) return dateEncrypt;
    try {
      final decoded = hashkit.decode(dateEncrypt).toString();
      final dateNumb = decoded;
      if (dateNumb.length < 8) return dateEncrypt;
      final yr = dateNumb.substring(0, dateNumb.length - 4);
      final mn = dateNumb.substring(dateNumb.length - 4, dateNumb.length - 2);
      final day = dateNumb.substring(dateNumb.length - 2);
      final out = '$yr-$mn-$day';
      debugPrint('[dateDecrtypt] in=$dateEncrypt out=$out');
      return out;
    } catch (e) {
      debugPrint('[dateDecrtypt] decode error for $dateEncrypt -> $e');
      return dateEncrypt;
    }
  }

  // ---------- notransEncrtypt2 / notransDecrtypt2 (safe) ----------
  static String notransEncrtypt2(String notrans) {
    if (notrans.isEmpty) return '';
    final parts = notrans.split('#');
    final out = <String>[];
    for (final p in parts) {
      if (p.trim().isEmpty) {
        out.add('');
        continue;
      }
      final valTrx = p.split('-');
      if (valTrx.length > 1) {
        final left = valTrx[0].trim();
        final right = valTrx[1].trim();
        final a = left.isEmpty ? '' : encryptNumber(left);
        final b = right.isEmpty ? '' : ('-' + encryptNumber(right));
        out.add(a + b);
      } else {
        final a =
            valTrx[0].trim().isEmpty ? '' : encryptNumber(valTrx[0].trim());
        out.add(a);
      }
    }
    final res = out.join('#');
    debugPrint('[notransEncrtypt2] in=$notrans out=$res');
    return res;
  }

  static String notransDecrtypt2(String notrans) {
    if (notrans.isEmpty) return '';
    final parts = notrans.split('#');
    final out = <String>[];
    for (final p in parts) {
      final valTrx = p.split('-');
      if (valTrx.length > 1) {
        final a = decryptNumber(valTrx[0]);
        final b = (valTrx[1].isEmpty) ? '' : ('-' + decryptNumber(valTrx[1]));
        out.add(a + b);
      } else {
        final a = decryptNumber(valTrx[0]);
        out.add(a);
      }
    }
    final res = out.join('#');
    debugPrint('[notransDecrtypt2] in=$notrans out=$res');
    return res;
  }
}
