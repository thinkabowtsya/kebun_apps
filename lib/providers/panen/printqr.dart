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

  printer.printNewLine();
  printer.printCustom('DOCKET', 2, 1);
  printer.printCustom(
      notransaksi.toUpperCase(), 1, 1); // size 2 = besar, align 1 = center
  printer.printNewLine();

  // --- QR CODE ---
  final profile = await CapabilityProfile.load(name: 'default');
  final generator = Generator(PaperSize.mm58, profile);
  final List<int> bytes = [];

  bytes.addAll(generator.qrcode(
    qrData,
    size: QRSize.size7,
    align: PosAlign.center,
  ));
  bytes.addAll(generator.feed(2));
  printer.writeBytes(Uint8List.fromList(bytes));
  await Future.delayed(const Duration(milliseconds: 400));

  // --- INFO DETAIL ---
  printer.printNewLine();

  void printAligned(String label, String value) {
    const int totalWidth = 32;
    String line = label.padRight(15); // label kiri max 15
    String val = value.padLeft(totalWidth - line.length);
    printer.printCustom("$line$val", 1, 0); // size 1 = normal, 0 = left align
  }

  printAligned("TPH", blok.toUpperCase());
  printAligned("Sesi", sesi);
  printAligned("Tanggal", tanggal);
  printAligned("Waktu", waktu);
  printAligned("Pemanen", pemanen);
  printAligned("Jjg", jjg);
  printAligned("Brondolan", brondolan);

  if (gradingList.isNotEmpty) {
    printer.printNewLine();
    printer.printCustom("Denda / Grading:", 1, 0);

    for (final g in gradingList) {
      final desc = (g['deskripsi'] ?? '-').toString();
      final jml = g['jml']?.toString() ?? '0';

      final left = desc.length > 24 ? desc.substring(0, 24) : desc;
      final line = left.padRight(25, ' ') + jml.padLeft(5);
      printer.printCustom(line, 1, 0);
    }
  }

  printer.printNewLine();
  printer.paperCut();
}
