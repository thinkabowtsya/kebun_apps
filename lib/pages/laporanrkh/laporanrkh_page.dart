import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/laporanrkh/laporanrkh_module.dart';
import 'package:flutter_application_3/providers/laporanrkh/laporanrkh_provider.dart';
import 'package:provider/provider.dart';

class RkhListPage extends StatefulWidget {
  const RkhListPage({super.key});

  @override
  State<RkhListPage> createState() => _RkhListPageState();
}

class _RkhListPageState extends State<RkhListPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => context.read<LaporanrkhProvider>().loadRkh());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan RKH')),
      body: Consumer<LaporanrkhProvider>(
        builder: (context, provider, _) {
          final data = provider.laporanRkhList;

          print(data);
          return RefreshIndicator(
            onRefresh: () => provider.loadRkh(),
            child: data.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Belum ada data RKH')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final row = data[index];
                      final notransaksi = (row['notransaksi'] ?? '').toString();
                      final asisten = (row['namakaryawan'] ?? '-').toString();

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            title: Text(
                              notransaksi.isEmpty
                                  ? '(tanpa nomor)'
                                  : notransaksi,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                asisten,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              final headerId =
                                  (row['notransaksi'] ?? '').toString();

                              Navigator.of(context).pushNamed(
                                '/list-rkh',
                                arguments: {
                                  'noTransaksi': headerId,
                                },
                              );
                            }),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
