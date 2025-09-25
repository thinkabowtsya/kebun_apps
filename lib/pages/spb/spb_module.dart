import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/sinkronisasi.dart';
import 'package:flutter_application_3/pages/haprestasipanen/formHA.dart';
import 'package:flutter_application_3/pages/haprestasipanen/haprestasipanen_page.dart';
import 'package:flutter_application_3/pages/spb/formspb.dart';
import 'package:flutter_application_3/pages/spb/generatespb.dart';
import 'package:flutter_application_3/pages/spb/lihatspb.dart';
import 'package:flutter_application_3/pages/spb/spb_page.dart';
import 'package:flutter_application_3/providers/cekRKH_provider.dart';
import 'package:flutter_application_3/providers/spb/spb_provider.dart';
import 'package:flutter_application_3/providers/sync_provider.dart';
import 'package:provider/provider.dart';

class SpbModule extends StatelessWidget {
  const SpbModule({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => (SpbProvider())),
      ChangeNotifierProvider(create: (_) => (SyncProvider())),
      ChangeNotifierProvider(create: (_) => CekRkhProvider()),
    ], child: const SpbNavigator());
  }
}

class SpbNavigator extends StatelessWidget {
  const SpbNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Navigator(
          initialRoute: '/',
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/':
                page = const SpbPage(); // default page
                break;
              case '/add':
                page = const FormSpbPage(
                  mode: FormSpbMode.add,
                );
                break;
              case '/edit':
                final args = settings.arguments as Map<String, dynamic>;
                page = FormSpbPage(
                  mode: args['mode'],
                  initialNoTransaksi: args['noTransaksi'],
                );
                break;
              case '/print-qr':
                final args = settings.arguments as Map<String, dynamic>;

                page = DocketSPBPage(
                  noTrans: args['noTransaksi'],
                );
                break;
              case '/sinkronisasi':
                page = const SinkronisasiPage();
                break;
              case '/lihat-spb':
                final args = settings.arguments as Map<String, dynamic>;
                // print(args['noTransaksi']);
                page = LihatSpb(
                  notransaksi: args['noTransaksi'],
                );
                break;

              default:
                page = const SpbPage();
            }

            return MaterialPageRoute(builder: (_) => page);
          },
        );
      },
    );
  }
}
