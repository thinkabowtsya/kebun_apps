import 'package:flutter/material.dart';
import 'package:flutter_application_3/halaman_utama.dart';
import 'package:flutter_application_3/widget/simple_table.dart';

class ButtomNavbar extends StatefulWidget {
  const ButtomNavbar({super.key});

  @override
  State<ButtomNavbar> createState() => _ButtomNavbarState();
}

class _ButtomNavbarState extends State<ButtomNavbar> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> page = [
    MainPage(),
    const DataTableExampleApp(),
    const Text('Setting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text(
          'PT. ALAM Mobile',
          style: TextStyle(
            color: Colors.white, // Mengatur warna teks menjadi putih
            fontWeight: FontWeight.bold, // Mengatur teks menjadi tebal (bold)
          ),
        ),
        backgroundColor: Colors.blue[800],
         actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Tambahkan fungsi refresh jika diperlukan
            },
          ),
        ],
      ),
      body: Center(
        child: IndexedStack(
          alignment: AlignmentDirectional.center,
          index: _selectedIndex,
          children: page,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        iconSize: 30,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800],
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
