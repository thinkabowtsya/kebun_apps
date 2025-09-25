// lib/services/hashkit.dart
// Port of hashkit.js to Dart
// Keep this file in lib/services/hashkit.dart

import 'dart:math';

class HashkitDart {
  static const String _defaultChars =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  final String chars;
  final bool shuffle;
  final bool mask;
  final int padding;
  final int seed; // 32-bit-ish seed

  HashkitDart([dynamic options])
      : chars = _resolveChars(options),
        shuffle = _resolveShuffle(options),
        mask = _resolveMask(options),
        padding = _resolvePadding(options),
        seed = _resolveSeed(options);

  // ------------------ Public API ------------------

  /// Encode accepts int, BigInt or numeric String. Returns encoded string.
  String encode(dynamic i) {
    BigInt n = _toBigInt(i);
    if (mask) {
      n = _getMaskedNum(n, seed, padding);
    }
    return _baseEncode(n, chars);
  }

  /// Decode returns BigInt (like JS number, but BigInt safer for large ints)
  BigInt decode(String s) {
    final num = _baseDecode(s, chars);
    if (mask) {
      final str = num.toString();
      if (str.length <= padding) return BigInt.zero;
      final remainder = str.substring(padding);
      return BigInt.parse(remainder);
    }
    return num;
  }

  // ------------------ Internal helpers ------------------

  static BigInt _toBigInt(dynamic v) {
    if (v is BigInt) return v;
    if (v is int) return BigInt.from(v);
    if (v is String) {
      final s = v.trim();
      // try parse safely; if not numeric, throw so callers can avoid passing such values.
      // We'll attempt to parse any numeric string; if empty -> throw FormatException here.
      return BigInt.parse(s);
    }
    // fallback
    return BigInt.from(int.tryParse(v.toString()) ?? 0);
  }

  static String _resolveChars(dynamic options) {
    if (options is String) {
      return _defaultChars;
    } else if (options is Map) {
      if (options.containsKey('shuffle') && options['shuffle'] == true) {
        final sd = options.containsKey('seed')
            ? _hashcode(options['seed'])
            : _hashcode(options.toString());
        final arr = _defaultChars.split('');
        final sh = _shuffle(arr, sd);
        return sh.join('');
      } else if (options.containsKey('chars')) {
        return options['chars']?.toString() ?? _defaultChars;
      } else {
        return _defaultChars;
      }
    }
    return _defaultChars;
  }

  static bool _resolveShuffle(dynamic options) {
    if (options is String) return false;
    if (options is Map && options.containsKey('shuffle'))
      return options['shuffle'] == true;
    return false;
  }

  static bool _resolveMask(dynamic options) {
    if (options is String) return false;
    if (options is Map && options.containsKey('mask'))
      return options['mask'] == true;
    return false;
  }

  static int _resolvePadding(dynamic options) {
    int p = 3;
    if (options is Map && options.containsKey('padding')) {
      final val = options['padding'];
      if (val is int) p = val;
    }
    if (p < 1) p = 1;
    if (p > 8) p = 8;
    return p;
  }

  static int _resolveSeed(dynamic options) {
    if (options is String) return _hashcode(options);
    if (options is Map && options.containsKey('seed')) {
      final s = options['seed'];
      if (s is int) return s;
      if (s is String) return _hashcode(s);
    }
    return 9999;
  }

  // baseEncode for BigInt
  static String _baseEncode(BigInt i, String chars) {
    if (i == BigInt.zero) return chars[0];
    final base = BigInt.from(chars.length);
    var n = i;
    final parts = <String>[];
    while (n > BigInt.zero) {
      final div = n ~/ base;
      final rem = (n - div * base).toInt();
      parts.add(chars[rem]);
      n = div;
    }
    return parts.reversed.join();
  }

  // baseDecode returns BigInt
  static BigInt _baseDecode(String s, String chars) {
    BigInt n = BigInt.zero;
    final base = BigInt.from(chars.length);
    for (var i = 0; i < s.length; i++) {
      final idx = chars.indexOf(s[i]);
      if (idx < 0) continue;
      final power = BigInt.from(s.length - i - 1);
      n += BigInt.from(idx) * _pow(base, power);
    }
    return n;
  }

  static BigInt _pow(BigInt base, BigInt exp) {
    BigInt result = BigInt.one;
    BigInt b = base;
    BigInt e = exp;
    while (e > BigInt.zero) {
      if ((e & BigInt.one) == BigInt.one) result *= b;
      b *= b;
      e = e >> 1;
    }
    return result;
  }

  // getMaskedNum replicates JS getMaskedNum behaviour
  static BigInt _getMaskedNum(BigInt i, int seed, int padding) {
    final x = _low32FromBigInt(i) ^ seed;
    final r = _random(x, 10);
    final max = pow(10, padding) - 1;
    final min = pow(10, padding - 1);
    final mask = (min + (r * (max - min))).floor();
    final concatenated = mask.toString() + i.toString();
    return BigInt.parse(concatenated);
  }

  // random replicates JS xorshift and returns double in [0,1)
  static double _random(int x, [int n = 1]) {
    int xi = x;
    for (var i = 0; i < n; i++) {
      xi = xi ^ _toInt32(xi << 21);
      xi = xi ^
          _unsignedRightShift(
              xi, 35); // shift may be larger than 31; we emulate
      xi = xi ^ _toInt32(xi << 4);
    }
    final ux = xi & 0xFFFFFFFF;
    return (ux.toDouble()) / 4294967296.0;
  }

  // hashcode like JS reduce ((a<<5)-a)+charCode & a
  static int _hashcode(dynamic str) {
    if (str is! String) {
      if (str is int) return str;
      return str.toString().hashCode;
    }
    int a = 0;
    for (var i = 0; i < str.length; i++) {
      final b = str.codeUnitAt(i);
      a = ((a << 5) - a) + b;
      a = a & 0xFFFFFFFF;
      if (a & 0x80000000 != 0) {
        a = a - 0x100000000;
      }
    }
    return a;
  }

  // shuffle function
  static List<String> _shuffle(List<String> array, int seed) {
    int i = array.length;
    while (i > 0) {
      final j = (_random(i ^ seed, 10) * i).floor();
      i--;
      final tmp = array[i];
      array[i] = array[j];
      array[j] = tmp;
    }
    return array;
  }

  // helper: take low 32 bits of BigInt
  static int _low32FromBigInt(BigInt v) {
    final mask = BigInt.from(0xFFFFFFFF);
    final low = (v & mask).toInt();
    return low;
  }

  // ensure to 32-bit signed int
  static int _toInt32(int x) {
    final masked = x & 0xFFFFFFFF;
    if (masked & 0x80000000 != 0) {
      return masked - 0x100000000;
    }
    return masked;
  }

  // unsigned right shift for possibly negative ints (simulate >>>)
  static int _unsignedRightShift(int value, int shift) {
    final s = shift & 31;
    final u = value & 0xFFFFFFFF;
    return (u >> s);
  }
}
