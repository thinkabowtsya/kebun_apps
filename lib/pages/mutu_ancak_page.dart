import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/setupmutu.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class MutuAncakPage extends StatelessWidget {
  const MutuAncakPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mutu Ancak'),
        ),
        body: const MutuAncakBody(),
      ),
    );
  }
}

class MutuAncakBody extends StatefulWidget {
  const MutuAncakBody({super.key});

  @override
  _MutuAncakBodyState createState() => _MutuAncakBodyState();
}

class _MutuAncakBodyState extends State<MutuAncakBody> {
  TextEditingController searchController = TextEditingController();
  List<MutuAncak> filteredmutuancak = [];

  @override
  void initState() {
    super.initState();
    // Fetch karyawan data when the page is initialized
    Future.delayed(Duration.zero, () {
      // Fetch data hanya jika belum ada data
      if (Provider.of<MasterdataProvider>(context, listen: false)
          .mutuancaks
          .isEmpty) {
        Provider.of<MasterdataProvider>(context, listen: false)
            .fetchMutuancaks();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredmutuancak =
          Provider.of<MasterdataProvider>(context, listen: false)
              .mutuancaks
              .where((mutuancak) {
        return mutuancak.kodemutu.toLowerCase().contains(query.toLowerCase()) ||
            mutuancak.namamutu.toLowerCase().contains(query.toLowerCase()) ||
            mutuancak.satuan.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredmutuancak selalu menggunakan data yang sudah difilter
        filteredmutuancak =
            filteredmutuancak.isEmpty ? provider.mutuancaks : filteredmutuancak;

        return Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged:
                    filterSearch, // Setiap perubahan pada input akan menjalankan filterSearch
                decoration: InputDecoration(
                  hintText: "Search..",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            // Jika tidak ada data yang ditemukan, tampilkan pesan "No Data"
            if (filteredmutuancak.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No Data Found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              // SCROLLABLE TABLE
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.8),
                      child: DataTable(
                        border: TableBorder.all(color: Colors.grey),
                        headingRowColor:
                            WidgetStateProperty.all(Colors.blueGrey[700]),
                        headingTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        columns: const [
                          DataColumn(label: Text("No")),
                          DataColumn(label: Text("Kode Mutu")),
                          DataColumn(label: Text("Nama")),
                          DataColumn(label: Text("Satuan")),
                        ],
                        rows: List.generate(filteredmutuancak.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(filteredmutuancak[index].kodemutu)),
                            DataCell(Text(filteredmutuancak[index].namamutu)),
                            DataCell(Text(filteredmutuancak[index].satuan)),
                            // Cek panjang sebelum substring
                          ]);
                        }),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
