import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/setuphama.dart';
import 'package:flutter_application_3/models/setupmutu.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class HamaPage extends StatelessWidget {
  const HamaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hama'),
        ),
        body: const HamaBody(),
      ),
    );
  }
}

class HamaBody extends StatefulWidget {
  const HamaBody({super.key});

  @override
  _HamaBodyState createState() => _HamaBodyState();
}

class _HamaBodyState extends State<HamaBody> {
  TextEditingController searchController = TextEditingController();
  List<Setuphama> filteredsetuphama = [];

  @override
  void initState() {
    super.initState();
    // Fetch karyawan data when the page is initialized
    Future.delayed(Duration.zero, () {
      // Fetch data hanya jika belum ada data
      if (Provider.of<MasterdataProvider>(context, listen: false)
          .setuphamas
          .isEmpty) {
        Provider.of<MasterdataProvider>(context, listen: false)
            .fetchSetuphama();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredsetuphama =
          Provider.of<MasterdataProvider>(context, listen: false)
              .setuphamas
              .where((setuphama) {
        return setuphama.kodehama.toLowerCase().contains(query.toLowerCase()) ||
            setuphama.namahama.toLowerCase().contains(query.toLowerCase()) ||
            setuphama.satuan.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredsetuphama selalu menggunakan data yang sudah difilter
        filteredsetuphama =
            filteredsetuphama.isEmpty ? provider.setuphamas : filteredsetuphama;

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
            if (filteredsetuphama.isEmpty)
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
                          DataColumn(label: Text("Kode Hama")),
                          DataColumn(label: Text("Nama")),
                          DataColumn(label: Text("Satuan")),
                        ],
                        rows: List.generate(filteredsetuphama.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(filteredsetuphama[index].kodehama)),
                            DataCell(Text(filteredsetuphama[index].namahama)),
                            DataCell(Text(filteredsetuphama[index].satuan)),
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
