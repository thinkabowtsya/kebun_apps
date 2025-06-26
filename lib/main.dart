import 'package:flutter/material.dart';
import 'package:flutter_application_3/halaman_utama.dart';
import 'package:flutter_application_3/pages/login_page.dart';
import 'package:flutter_application_3/providers/notrans_provider.dart';
import 'package:flutter_application_3/providers/tambahdata_bkm_provider.dart';
import 'package:flutter_application_3/providers/user_provider.dart';
// import 'package:flutter_application_3/widget/buttom_navbar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NoTransaksiProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return userProvider.isLoggedIn ? MainPage() : const LoginPage();
        },
      ),
    );
  }
}
