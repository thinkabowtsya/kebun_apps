import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/sinkronisasi.dart';
import 'package:flutter_application_3/pages/panen/detailpanen.dart';
import 'package:flutter_application_3/pages/panen/formpanen.dart';
import 'package:flutter_application_3/pages/panen/lihatpanen.dart';
import 'package:flutter_application_3/pages/panen/list-printer.dart';
import 'package:flutter_application_3/pages/panen/mutubuah.dart';
import 'package:flutter_application_3/pages/panen/prestasipanen.dart';
import 'package:flutter_application_3/pages/panen/viewdetail.dart';
import 'package:flutter_application_3/pages/panen_page.dart';
import 'package:flutter_application_3/providers/cekRKH_provider.dart';
import 'package:flutter_application_3/providers/panen/detail_provider.dart';
import 'package:flutter_application_3/pages/panen/generate_qr_code.dart';
import 'package:flutter_application_3/providers/panen/mutubuah_provider.dart';
import 'package:flutter_application_3/providers/panen/panen_provider.dart';
import 'package:flutter_application_3/providers/panen/prestasi_provider.dart';
import 'package:flutter_application_3/providers/panen/qr_provider.dart';
import 'package:flutter_application_3/providers/sync_provider.dart';
import 'package:provider/provider.dart';

class PanenModule extends StatelessWidget {
  const PanenModule({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => PanenProvider()),
      ChangeNotifierProvider(create: (_) => PrestasiProvider()),
      ChangeNotifierProvider(create: (_) => DetailProvider()),
      ChangeNotifierProvider(create: (_) => MutuBuahProvider()),
      ChangeNotifierProvider(create: (_) => PanenQrProvider()),
      ChangeNotifierProvider(create: (_) => SyncProvider()),
      ChangeNotifierProvider(create: (_) => CekRkhProvider()),
    ], child: const PanenNavigator());
  }
}

class PanenNavigator extends StatelessWidget {
  const PanenNavigator({super.key});

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
                page = const PanenPage(); // default page
                break;
              case '/add':
                page = const FormPanenPage(
                  mode: FormPanenMode.add,
                );
                break;
              case '/add-prestasi':
                page = const FormPrestasiPanenPage(
                  mode: FormPrestasiPanenMode.add,
                );
                break;
              case '/detail-panen':
                final args = settings.arguments as Map<String, dynamic>;

                page = DetailPanenPage(
                  mode: DetailPanenMode.add,
                  blok: args['blok'],
                );
                break;
              case '/mutu-buah':
                final args = settings.arguments as Map<String, dynamic>;

                page = MutuBuahPanenPage(
                  mode: MutuBuahPanenMode.add,
                  blok: args['blok'],
                );
                break;

              case '/print-qr':
                final args = settings.arguments as Map<String, dynamic>;

                page = PrintQrPage(
                  noTrans: args['noTransaksi'],
                  blok: args['blok'],
                  rotasi: args['rotasi'],
                  nik: args['nik'],
                );
                break;

              case '/list-printer':
                final args = settings.arguments as Map<String, dynamic>;

                page = ListPrinterPage(
                  noTrans: args['noTransaksi'],
                  blok: args['blok'],
                  rotasi: args['rotasi'],
                  nik: args['nik'],
                );
                break;
              case '/edit':
                final args = settings.arguments as Map<String, dynamic>;
                page = FormPanenPage(
                  mode: args['mode'],
                  initialNoTransaksi: args['noTransaksi'],
                );
                break;

              case '/edit-prestasipanen':
                final args = settings.arguments as Map<String, dynamic>;

                page = FormPrestasiPanenPage(
                    mode: FormPrestasiPanenMode.edit,
                    notransaksi: args['noTransaksi'],
                    nik: args['nik']);
                break;
              case '/edit-detail':
                final args = settings.arguments as Map<String, dynamic>;

                page = DetailPanenPage(
                  mode: DetailPanenMode.edit,
                  notph: args['notph'],
                  notransaksi: args['noTransaksi'],
                  rotasi: args['rotasi'],
                  blok: args['blok'],
                  nik: args['nik'],
                );
                break;
              case '/lihat-panen':
                final args = settings.arguments as Map<String, dynamic>;
                page = LihatPanen(
                  notransaksi: args['noTransaksi'],
                );
                break;
              case '/sinkronisasi':
                page = const SinkronisasiPage();
                break;

              case '/view-detailpanen':
                final args = settings.arguments as Map<String, dynamic>;

                // print(args);
                page = LihatDetailPanen(
                  notransaksi: args['noTransaksi'],
                  nik: args['nik'],
                  namakaryawan: args['namakaryawan'],
                );
                break;

              default:
                page = const PanenPage();
            }

            return MaterialPageRoute(builder: (_) => page);
          },
        );
      },
    );
  }
}
