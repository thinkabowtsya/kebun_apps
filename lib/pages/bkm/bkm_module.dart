import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/bkm/absensi.dart';
import 'package:flutter_application_3/pages/bkm/addData.dart';
import 'package:flutter_application_3/pages/bkm/addKehadiran.dart';
import 'package:flutter_application_3/pages/bkm/addPrestasi.dart';
import 'package:flutter_application_3/pages/bkm/editPrestasi.dart';
import 'package:flutter_application_3/pages/bkm/lihatbkm.dart';
import 'package:flutter_application_3/pages/bkm/material.dart';
import 'package:flutter_application_3/pages/bkm/sinkronisasi.dart';
import 'package:flutter_application_3/pages/bkm_page.dart';
import 'package:flutter_application_3/pages/sinkron_page.dart';
import 'package:flutter_application_3/providers/bkm/absensi_provider.dart';
import 'package:flutter_application_3/providers/bkm/bkm_provider.dart';
import 'package:flutter_application_3/providers/bkm/kehadiran_provider.dart';
import 'package:flutter_application_3/providers/bkm/material_provider.dart';
import 'package:flutter_application_3/providers/bkm/prestasi_provider.dart';
import 'package:flutter_application_3/providers/cekRKH_provider.dart';
import 'package:flutter_application_3/providers/sync_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
import 'package:provider/provider.dart';

class BkmModule extends StatelessWidget {
  const BkmModule({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => BkmProvider()),
      ChangeNotifierProvider(create: (_) => PrestasiProvider()),
      ChangeNotifierProvider(create: (_) => KehadiranProvider()),
      ChangeNotifierProvider(create: (_) => MaterialProvider()),
      ChangeNotifierProvider(create: (_) => AbsensiProvider()),
      ChangeNotifierProvider(create: (_) => SyncProvider()),
      ChangeNotifierProvider(create: (_) => CekRkhProvider()),
    ], child: const BkmNavigator());
  }
}

class BkmNavigator extends StatelessWidget {
  const BkmNavigator({super.key});

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
                page = const BukuKerjaMandorPage(); // default page
                break;
              case '/add':
                page = const AddDataPage(
                  mode: BkmFormMode.add,
                );
                break;
              case '/edit':
                final args = settings.arguments as Map<String, dynamic>;
                page = AddDataPage(
                  mode: args['mode'],
                  initialNoTransaksi: args['noTransaksi'],
                );
                break;

              case '/add-prestasi':
                page = AddPrestasiPage();
                break;
              case '/edit-prestasi':
                final args = settings.arguments as Map<String, dynamic>;
                page = EditPrestasiPage();
                break;
              case '/add-kehadiran':
                page = const TambahKehadiranPage(mode: KehadairanFormMode.add);
                break;
              case '/edit-kehadiran':
                final args = settings.arguments as Map<String, dynamic>;
                page = TambahKehadiranPage(
                  mode: args['mode'],
                  dataList: args['data'],
                );
                break;
              case '/add-material':
                page = const FormMaterialPage();
                break;
              case '/add-absensi':
                page = const FormAbsensiPage();
                break;
              case '/lihat-bkm':
                final args = settings.arguments as Map<String, dynamic>;
                // print(args['noTransaksi']);
                page = LihatBkm(
                  notransaksi: args['noTransaksi'],
                );
                break;
              case '/sinkronisasi':
                page = const SinkronisasiPage();
                break;
              default:
                page = const BukuKerjaMandorPage();
            }

            return MaterialPageRoute(builder: (_) => page);
          },
        );
      },
    );
  }
}
