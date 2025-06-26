import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/blok.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class BlokPage extends StatelessWidget {
  const BlokPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blok'),
        ),
        body: const BlokBody(),
      ),
    );
  }
}

class BlokBody extends StatefulWidget {
  const BlokBody({super.key});

  @override
  _BlokBodyState createState() => _BlokBodyState();
}

class _BlokBodyState extends State<BlokBody> {
  TextEditingController searchController = TextEditingController();
  List<Blok> filteredBlok = [];

  @override
  void initState() {
    super.initState();
    // Fetch karyawan data when the page is initialized
    Future.delayed(Duration.zero, () {
      // Fetch data hanya jika belum ada data
      if (Provider.of<MasterdataProvider>(context, listen: false)
          .bloks
          .isEmpty) {
        Provider.of<MasterdataProvider>(context, listen: false).fetchBloks();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredBlok = Provider.of<MasterdataProvider>(context, listen: false)
          .bloks
          .where((blok) {
        // Pencarian berdasarkan nama, nik, dan subbagian
        return blok.kodeblok.toLowerCase().contains(query.toLowerCase()) ||
            blok.tahuntanam.toLowerCase().contains(query.toLowerCase()) ||
            blok.luasareaproduktif.toString().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredBlok selalu menggunakan data yang sudah difilter
        filteredBlok = filteredBlok.isEmpty ? provider.bloks : filteredBlok;

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
            if (filteredBlok.isEmpty)
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
                          DataColumn(label: Text("Unit")),
                          DataColumn(label: Text("Divisi")),
                          DataColumn(label: Text("Blok")),
                          DataColumn(label: Text("Tahun Tanam")),
                          DataColumn(label: Text("Luas")),
                          DataColumn(label: Text("SPH")),
                          DataColumn(label: Text("Pokok")),
                        ],
                        rows: List.generate(filteredBlok.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(filteredBlok[index].kodeblok.length >=
                                    4
                                ? filteredBlok[index].kodeblok.substring(0, 4)
                                : '')),
                            DataCell(Text(filteredBlok[index].kodeblok.length >=
                                    6
                                ? filteredBlok[index].kodeblok.substring(4, 6)
                                : '')),
                            DataCell(Text(filteredBlok[index].kodeblok.length >=
                                    8
                                ? filteredBlok[index].kodeblok.substring(6, 10)
                                : '')),
                            DataCell(Text(filteredBlok[index].tahuntanam)),
                            DataCell(Text(filteredBlok[index]
                                .luasareaproduktif
                                .toString())),
                            DataCell(Text((filteredBlok[index].jumlahpokok /
                                    filteredBlok[index].luasareaproduktif)
                                .round()
                                .toString())), // Cek panjang sebelum substring
                            DataCell(Text(filteredBlok[index]
                                .jumlahpokok
                                .toString())), // Cek panjang sebelum substring
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
