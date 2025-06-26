import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/setuphama.dart';
import 'package:flutter_application_3/models/setupmutu.dart';
import 'package:flutter_application_3/models/setuptph.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class TphPage extends StatelessWidget {
  const TphPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TPH'),
        ),
        body: const TphBody(),
      ),
    );
  }
}

class TphBody extends StatefulWidget {
  const TphBody({super.key});

  @override
  _TphBodyState createState() => _TphBodyState();
}

class _TphBodyState extends State<TphBody> {
  TextEditingController searchController = TextEditingController();
  List<Setuptph> filteredsetuptph = [];

  @override
  void initState() {
    super.initState();
    // Fetch karyawan data when the page is initialized
    Future.delayed(Duration.zero, () {
      // Fetch data hanya jika belum ada data
      if (Provider.of<MasterdataProvider>(context, listen: false)
          .setuptphs
          .isEmpty) {
        Provider.of<MasterdataProvider>(context, listen: false).fetchSetuptph();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredsetuptph = Provider.of<MasterdataProvider>(context, listen: false)
          .setuptphs
          .where((setuptph) {
        return setuptph.kode.toLowerCase().contains(query.toLowerCase()) ||
            setuptph.luas.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredsetuptph selalu menggunakan data yang sudah difilter
        filteredsetuptph =
            filteredsetuptph.isEmpty ? provider.setuptphs : filteredsetuptph;

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
            if (filteredsetuptph.isEmpty)
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
                          DataColumn(label: Text("TPH")),
                          DataColumn(label: Text("Luas")),
                        ],
                        rows: List.generate(filteredsetuptph.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(filteredsetuptph[index].kode.length >=
                                    4
                                ? filteredsetuptph[index].kode.substring(0, 4)
                                : '')),
                            DataCell(Text(filteredsetuptph[index].kode.length >=
                                    6
                                ? filteredsetuptph[index].kode.substring(4, 6)
                                : '')),
                            DataCell(Text(filteredsetuptph[index].kode.length >=
                                    8
                                ? filteredsetuptph[index].kode.substring(6, 10)
                                : '')),
                            DataCell(Text(filteredsetuptph[index].kode.length >=
                                    8
                                ? filteredsetuptph[index].kode.substring(7, 9)
                                : '')),
                            DataCell(Text(filteredsetuptph[index].luas)),
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
