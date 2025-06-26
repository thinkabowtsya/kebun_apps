import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/kebun_page.dart';
import 'package:flutter_application_3/pages/master_page.dart';
import 'package:flutter_application_3/pages/login_page.dart';
import 'package:flutter_application_3/pages/setup_page.dart';
import 'package:flutter_application_3/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // Navigasi ke halaman yang sesuai berdasarkan menu yang dipilih
  void navigateToPage(BuildContext context, String caption) {
    caption = caption.replaceAll(RegExp(r'{|}'), '');

    if (caption == "kebun") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => KebunPage(),
        ),
      );
    } else if (caption == "masterdata") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MasterPage(),
        ),
      );
    } else if (caption == "Logout") {
      Provider.of<UserProvider>(context, listen: false).logout();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else if (caption == "Setup") {
      // Logic untuk Setup
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SetupPage(),
        ),
      );
      // Provider.of<UserProvider>(context, listen: false).logout();
    } else if (caption == "About") {
      // Logic untuk About
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Navigating to About")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Klik $caption")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PT. ALAM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          var masterMenuItems = userProvider.menuItems
              .where((menuItem) => menuItem['type'] == 'master')
              .toList();

          var allMenuItems = [
            ...masterMenuItems,
            {
              'caption': 'Setup',
              'type': 'static',
              'icon': 'settings',
            },
            {
              'caption': 'About',
              'type': 'static',
              'icon': 'info',
            },
            {
              'caption': 'Logout',
              'type': 'static',
              'icon': 'info',
            },
          ];

          print(context);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: allMenuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final menuItem = allMenuItems[index];
                return GestureDetector(
                  onTap: () => navigateToPage(context, menuItem['caption']),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          IconData(
                            0xe800,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        menuItem['caption'].replaceAll(RegExp(r'{|}'), ''),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
