import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/basis_norma_page.dart';
import 'package:flutter_application_3/providers/sinkron_provider.dart';
import 'package:provider/provider.dart';

class SinkronPage extends StatelessWidget {
  const SinkronPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SinkronProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sinkronisasi'),
        ),
        body: SinkronBody(),
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class SinkronBody extends StatelessWidget {
  // List data menu
  final List<Map<String, dynamic>> menuItems = [
    {"title": "Master Data", "isHeader": false, "page": "master"},
    {"title": "Transaksi", "isHeader": false, "page": "transaksi"},
  ];

  void navigateToPage(
      BuildContext context, String page, SinkronProvider sinkronProvider) {
    if (page == "master") {
      // Sinkronisasi dilakukan ketika Master Data dipilih
      sinkronProvider.sinkronisasi().then((_) {
        // Menampilkan snackbar setelah sinkronisasi selesai
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync sudah selesai!')),
        );
      }).catchError((error) {
        // Menampilkan snackbar jika terjadi error saat sinkronisasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat sinkronisasi: $error')),
        );
      });
    } else if (page == 'transaksi') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BasisNormaKegiatanPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sinkronProvider = Provider.of<SinkronProvider>(context);

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];

        if (item["isHeader"]) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              item["title"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () =>
                  navigateToPage(context, item['page'], sinkronProvider),
              child: Text(
                item["title"],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        }
      },
    );
  }
}
