import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/sinkronisasi.dart';
import 'package:flutter_application_3/pages/haprestasipanen/formHA.dart';
import 'package:flutter_application_3/pages/haprestasipanen/haprestasipanen_page.dart';
import 'package:flutter_application_3/pages/haprestasipanen/lihathapanen.dart';
import 'package:flutter_application_3/pages/haprestasipanen/prestasipanen.dart';
import 'package:flutter_application_3/pages/haprestasipanen/viewdetail.dart';
import 'package:flutter_application_3/providers/cekRKH_provider.dart';
import 'package:flutter_application_3/providers/haprestasipanen/haprestasipanen_provider.dart';
import 'package:flutter_application_3/providers/haprestasipanen/prestasi_provider.dart';
import 'package:flutter_application_3/providers/sync_provider.dart';
import 'package:provider/provider.dart';

class HaPrestasiPanenModule extends StatelessWidget {
  const HaPrestasiPanenModule({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => (HaPrestasiPanenProvider())),
      ChangeNotifierProvider(create: (_) => (PrestasiProvider())),
      ChangeNotifierProvider(create: (_) => (SyncProvider())),
      ChangeNotifierProvider(create: (_) => CekRkhProvider()),
    ], child: const HaPrestasiNavigator());
  }
}

class HaPrestasiNavigator extends StatelessWidget {
  const HaPrestasiNavigator({super.key});

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
                page = const HaPrestasiPage(); // default page
                break;

              case '/add':
                page = const FormHAPage(
                  mode: FormHAMode.add,
                );
                break;
              case '/add-prestasi':
                page = const HAPrestasiPanenPage(
                  mode: HAPrestasiPanenMode.add,
                );
                break;
              case '/edit':
                final args = settings.arguments as Map<String, dynamic>;
                page = FormHAPage(
                  mode: args['mode'],
                  initialNoTransaksi: args['noTransaksi'],
                );
                break;
              case '/edit-prestasipanen':
                final args = settings.arguments as Map<String, dynamic>;

                page = HAPrestasiPanenPage(
                    mode: HAPrestasiPanenMode.edit,
                    notransaksi: args['noTransaksi'],
                    nik: args['nik']);
                break;
              case '/sinkronisasi':
                page = const SinkronisasiPage();
                break;
              case '/liat-hapanen':
                final args = settings.arguments as Map<String, dynamic>;
                // print(args['noTransaksi']);
                page = LihatHAPanen(
                  notransaksi: args['noTransaksi'],
                );
                break;

              case '/view-detailhapanen':
                final args = settings.arguments as Map<String, dynamic>;

                page = LihatHADetailPanen(
                  notransaksi: args['noTransaksi'],
                  nik: args['nik'],
                  namakaryawan: args['namakaryawan'],
                );
                break;

              default:
                page = const HaPrestasiPage();
            }

            return MaterialPageRoute(builder: (_) => page);
          },
        );
      },
    );
  }
}
