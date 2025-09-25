import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/kebun_page.dart';
import 'package:flutter_application_3/pages/master_page.dart';
import 'package:flutter_application_3/pages/login_page.dart';
import 'package:flutter_application_3/pages/setup_page.dart';
import 'package:flutter_application_3/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // --- Helpers --------------------------------------------------------------

  String _normalizeCaption(String caption) {
    // hilangkan { }, spasi, dan non-alfanumerik → huruf kecil
    return caption.replaceAll(RegExp(r'{|}'), '').trim().toLowerCase();
  }

  IconData pickIconForCaption(String rawCaption) {
    final key = _normalizeCaption(rawCaption);

    // mapping standar (boleh tambah sesuai modul kamu)
    switch (key) {
      case 'kebun':
        return Icons.park_rounded; // pohon / kebun
      case 'masterdata':
      case 'master':
      case 'data':
        return Icons.table_chart_rounded; // tabel / master data
      case 'panen':
        return Icons.agriculture; // ikon pertanian/panen
      case 'kehadiran':
        return Icons.event_available_rounded; // absensi/kehadiran
      case 'material':
        return Icons.inventory_2_rounded; // material/inventory
      case 'bkm':
      case 'prestasi':
        return Icons.assignment_turned_in_rounded; // form / prestasi
      case 'spb':
        return Icons.local_shipping_rounded; // logistik/SPB
      case 'setup':
        return Icons.settings_rounded;
      case 'about':
        return Icons.info_outline_rounded;
      case 'logout':
        return Icons.logout_rounded;

      // fallback umum
      default:
        return Icons.apps_rounded;
    }
  }

  Color pickColorForCaption(String rawCaption) {
    final key = _normalizeCaption(rawCaption);
    switch (key) {
      case 'kebun':
        return Colors.green.shade700;
      case 'masterdata':
      case 'master':
        return Colors.blue.shade700;
      case 'panen':
        return Colors.orange.shade700;
      case 'kehadiran':
        return Colors.teal.shade700;
      case 'material':
        return Colors.purple.shade700;
      case 'setup':
        return Colors.indigo.shade700;
      case 'about':
        return Colors.cyan.shade700;
      case 'logout':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }

  // Navigasi ke halaman yang sesuai berdasarkan menu yang dipilih
  void navigateToPage(BuildContext context, String caption) {
    final key = caption.replaceAll(RegExp(r'{|}'), '');

    if (key == "kebun") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => KebunPage()),
      );
    } else if (key == "masterdata") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MasterPage()),
      );
    } else if (key == "Logout") {
      Provider.of<UserProvider>(context, listen: false).logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else if (key == "Setup") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SetupPage()),
      );
    } else if (key == "About") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Navigating to About")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Klik $key")),
      );
    }
  }

  // --- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PT. ALAM',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final masterMenuItems = userProvider.menuItems
              .where((menuItem) => menuItem['type'] == 'master')
              .toList();

          final allMenuItems = [
            ...masterMenuItems,
            {'caption': 'Setup', 'type': 'static'},
            {'caption': 'About', 'type': 'static'},
            {'caption': 'Logout', 'type': 'static'},
          ];

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
                final rawCaption = (menuItem['caption'] ?? '').toString();
                final cleanCaption = rawCaption.replaceAll(RegExp(r'{|}'), '');

                final iconData = pickIconForCaption(rawCaption);
                final color = pickColorForCaption(rawCaption);

                return GestureDetector(
                  onTap: () => navigateToPage(context, cleanCaption),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: color,
                        child: Icon(iconData, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cleanCaption,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
