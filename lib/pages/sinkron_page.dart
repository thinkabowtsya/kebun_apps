import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_3/providers/sinkron_provider.dart';
import 'package:flutter_application_3/providers/user_provider.dart';
import 'package:flutter_application_3/pages/basis_norma_page.dart';

class SinkronPage extends StatelessWidget {
  const SinkronPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SinkronProvider diasumsikan sudah diregister di root.
    return Scaffold(
      appBar: AppBar(title: const Text('Sinkronisasi')),
      body: const _SinkronBody(),
    );
  }
}

class _SinkronBody extends StatefulWidget {
  const _SinkronBody();

  @override
  State<_SinkronBody> createState() => _SinkronBodyState();
}

class _SinkronBodyState extends State<_SinkronBody> {
  bool _showStatus = false; // ← panel status hanya muncul setelah ditekan

  List<Map<String, dynamic>> get menuItems => const [
        {"title": "Master Data", "page": "master"},
        {"title": "Transaksi", "page": "transaksi"},
      ];

  Future<Map<String, String>> _getCreds(BuildContext context) async {
    final userProv = context.read<UserProvider>();
    var username = userProv.username.trim();
    var password = userProv.password; // ganti ke token jika sudah ada

    if (username.isEmpty || password.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      username = (prefs.getString('username') ?? '').trim();
      password =
          prefs.getString('password') ?? ''; // atau prefs.getString('token')
    }
    return {'username': username, 'password': password};
  }

  Future<void> _onTapMenu(
    BuildContext context,
    String page,
    SinkronProvider sinkron,
  ) async {
    if (page == 'master') {
      // tampilkan panel status
      if (!_showStatus) setState(() => _showStatus = true);

      final creds = await _getCreds(context);
      final username = creds['username'] ?? '';
      final password = creds['password'] ?? '';

      if (username.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Tidak menemukan kredensial. Silakan login ulang.')),
        );
        return;
      }

      try {
        await sinkron.sinkronisasi(username: username, password: password);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync sudah selesai!')),
        );
      } catch (e) {
        if (!mounted) return;
        print('Error saat sinkronisasi: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat sinkronisasi: $e')),
        );
      }
    } else if (page == 'transaksi') {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BasisNormaKegiatanPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sinkron = context.watch<SinkronProvider>();

    return Column(
      children: [
        // ======= PANEL STATUS & PROGRESS (muncul hanya setelah ditekan) =======
        if (_showStatus)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status Sinkronisasi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      // saat sync & progress==0 → indeterminate; selesai/idle → 0.0
                      value: sinkron.isSyncing
                          ? (sinkron.progress == 0.0 ? null : sinkron.progress)
                          : 0.0,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          sinkron.isSyncing ? Icons.sync : Icons.check_circle,
                          size: 18,
                          color: sinkron.isSyncing ? Colors.blue : Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            sinkron.message.isNotEmpty
                                ? sinkron.message
                                : (sinkron.isSyncing
                                    ? 'Sedang sinkronisasi...'
                                    : 'Siap sinkronisasi'),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ),
                        if (sinkron.isSyncing && sinkron.progress > 0)
                          Text(
                            '${(sinkron.progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ======= LIST MENU =======
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: menuItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isMaster = item['page'] == 'master';
              final isBusy = sinkron.isSyncing && isMaster;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isBusy
                    ? null
                    : () => _onTapMenu(context, item['page'], sinkron),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isMaster && sinkron.isSyncing) ...[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Icon(isMaster ? Icons.cloud_sync : Icons.assignment,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      item['title'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
