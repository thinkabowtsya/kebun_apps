import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  final void Function(String)? onScan; // ✅ callback opsional

  const QrScanPage({Key? key, this.onScan}) : super(key: key);

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _dialogShown = false; // supaya tidak muncul dialog berkali-kali

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_dialogShown)
                return; // jika dialog sudah tampil, abaikan scan berikutnya

              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final value = barcodes.first.rawValue;
                if (value != null) {
                  _dialogShown = true;
                  _controller.stop(); // ⏸️ pause scanner

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text("QR Terdeteksi"),
                      content: Text(
                          "SPB Sudah Berhasil Di Scan. Ingin Melanjutkan?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _dialogShown = false;
                            Navigator.of(ctx).pop();
                            _controller.start(); // ▶️ resume scanner
                          },
                          child: const Text("Scan Lagi"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            widget.onScan?.call(value); // ✅ panggil callback
                            Navigator.of(ctx).pop(); // tutup dialog
                            Navigator.of(context)
                                .pop(value); // ✅ return ke halaman sebelumnya
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),

          // overlay kotak
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // teks instruksi
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Arahkan QR code ke kotak di atas",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
