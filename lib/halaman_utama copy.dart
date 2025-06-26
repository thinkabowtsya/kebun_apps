import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/kebun_page.dart';
import 'package:flutter_application_3/pages/login_page.dart';
import 'package:flutter_application_3/pages/master_page.dart';
import 'package:flutter_application_3/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.attach_money, "label": "Keuangan", "color": Colors.green},
    {"icon": Icons.shopping_basket, "label": "Pengadaan", "color": Colors.teal},
    {"icon": Icons.factory, "label": "Pabrik", "color": Colors.orange},
    {"icon": Icons.nature, "label": "Kebun", "color": Colors.green},
    {"icon": Icons.storage, "label": "Masterdata", "color": Colors.yellow},
    {"icon": Icons.approval, "label": "Approval", "color": Colors.lightGreen},
    {"icon": Icons.settings, "label": "Setup", "color": Colors.brown},
    {"icon": Icons.info, "label": "About", "color": Colors.blue},
    {"icon": Icons.info, "label": "Logout", "color": Colors.blue},
  ];

  MainPage({super.key});

  // const MainPage({super.key});

  void navigateToPage(BuildContext context, String label) {
    if (label == "Kebun") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => KebunPage(),
        ),
      );
    } else if (label == "Masterdata") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MasterPage(),
        ),
      );
    } else if (label == "Logout") {
      Provider.of<UserProvider>(context, listen: false).logout();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Klik $label")),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => navigateToPage(context, menuItems[index]['label']),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: menuItems[index]['color'],
                    child: Icon(menuItems[index]['icon'],
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(menuItems[index]['label'],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
