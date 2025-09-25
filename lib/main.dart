// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/db_helper.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_3/halaman_utama.dart';
import 'package:flutter_application_3/pages/login_page.dart';
import 'package:flutter_application_3/providers/notrans_provider.dart';
import 'package:flutter_application_3/providers/sinkron_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
import 'package:flutter_application_3/providers/user_provider.dart';
import 'package:flutter_application_3/services/sync_service.dart';
// DBHelper singleton

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database di awal (opsional, tapi berguna untuk memastikan file DB dibuat)
  try {
    await DBHelper().database;
    debugPrint('Database initialized');
  } catch (e) {
    debugPrint('Failed to init DB: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NoTransaksiProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(
          create: (_) => SinkronProvider(SyncRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Saya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await context.read<UserProvider>().restoreSession();
    } catch (e) {
      debugPrint('restoreSession failed: $e');
    }
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final loggedIn = context.watch<UserProvider>().isLoggedIn;
    return loggedIn ? const MainPage() : const LoginPage();
  }
}
