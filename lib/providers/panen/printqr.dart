import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

Future<void> printQrAndInfo({
  required String qrData,
  required String sesi,
  required String tanggal,
  required String waktu,
  required String pemanen,
  required String jjg,
  required String brondolan,
  required String blok,
  required String notransaksi,
  required List<Map<String, dynamic>> gradingList,
}) async {
  final printer = BlueThermalPrinter.instance;

  printer.printCustom('DOCKET', 2, 1);
  printer.printCustom(notransaksi.toUpperCase(), 1, 1);

  final profile = await CapabilityProfile.load(name: 'default');
  final generator = Generator(PaperSize.mm58, profile);
  final List<int> bytes = [];

  bytes.addAll(generator.qrcode(
    qrData,
    size: QRSize.size2,
    align: PosAlign.center,
  ));

  printer.writeBytes(Uint8List.fromList(bytes));

  await Future.delayed(const Duration(milliseconds: 120));

  void printAligned(String label, String value) {
    const int totalWidth = 20;
    final leftLabel = label.length > 15 ? label.substring(0, 15) : label;
    final val = value;

    final int remaining = totalWidth - leftLabel.length - val.length;

    String middle;
    if (remaining > 0) {
      middle = ' ' * remaining;
    } else {
      final allowedValLen = totalWidth - leftLabel.length;
      final truncatedVal =
          allowedValLen > 0 ? val.substring(0, allowedValLen) : '';

      printer.printCustom(leftLabel + truncatedVal, 1, 0);
      return;
    }

    final line = leftLabel + middle + val;
    printer.printCustom(line, 1, 0);
  }

  printAligned("TPH", blok.toUpperCase());
  printAligned("Sesi", sesi);
  printAligned("Tanggal", tanggal);
  printAligned("Waktu", waktu);
  printAligned("Pemanen", pemanen);
  printAligned("Jjg", jjg);
  printAligned("Brondolan", brondolan);

  if (gradingList.isNotEmpty) {
    printer.printCustom("Denda / Grading:", 1, 0);
    for (final g in gradingList) {
      final desc = (g['deskripsi'] ?? '-').toString();
      final jml = g['jml']?.toString() ?? '0';
      final left = desc.length > 24 ? desc.substring(0, 24) : desc;
      final line = left.padRight(25) + jml.padLeft(5);
      printer.printCustom(line, 1, 0);
    }
  }
}
