// lib/modules/laporan_rkh_module.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/laporanrkh/laporankehadiranrkh_page.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_3/providers/laporanrkh/laporanrkh_provider.dart';
import 'package:flutter_application_3/pages/laporanrkh/laporanrkh_page.dart';

/// Route names khusus modul RKH
class RkhRoutes {
  static const root = '/';
  static const detail = '/detail';
}

/// Args yang dikirim saat pushNamed ke halaman detail
class RkhDetailArgs {
  final String id; // notransaksi
  const RkhDetailArgs({required this.id});
}

class LaporanRKHModule extends StatelessWidget {
  const LaporanRKHModule({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LaporanrkhProvider()),
      ],
      child: const LaporanRKHNavigator(),
    );
  }
}

class LaporanRKHNavigator extends StatelessWidget {
  const LaporanRKHNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: RkhRoutes.root,
      onGenerateRoute: (settings) {
        late final Widget page;

        switch (settings.name) {
          case RkhRoutes.root:
            page = const RkhListPage();
            break;

          case '/list-rkh':
            final args = settings.arguments as Map<String, dynamic>;
            page = RkhDetailPage(id: args['noTransaksi']);
            break;

          default:
            page = const RkhListPage();
        }

        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
