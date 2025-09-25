import 'package:intl/intl.dart';

class ApiConstants {
  static const String ip = "114.9.80.64";
  static const String apiBaseUrl = "http://114.9.80.64/owl/mobile/";
  // static const String apiBaseUrl =
  //     "https://ca1f2a9e8c21.ngrok-free.app/script_dev/mobile/";
  // static const String apiBaseUrlTesting = "http://114.9.80.64:8074/dev/mobile";
  static const String apiBaseUrlTesting = "http://114.9.80.64:8074/dev/mobile";
  // static const String apiBaseUrlTesting =
  //     "https://5eecac17f89d.ngrok-free.app/script_dev/mobile";
  static const String apiKey = "123456";
}

class DateTimeUtils {
  DateTimeUtils._(); // private constructor supaya tidak bisa diinstansiasi

  /// Format tanggal: YYYY-MM-DD
  static String tanggalSekarang() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  /// Format waktu: HH:mm:ss
  static String timeSekarang() {
    final now = DateTime.now();
    return DateFormat('HH:mm:ss').format(now);
  }

  /// Gabungan tanggal + waktu, misal "2025-07-22 14:35:07"
  static String lastUpdate() {
    return '${tanggalSekarang()} ${timeSekarang()}';
  }
}
