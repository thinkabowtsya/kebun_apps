import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/kegiatan.dart';
import 'package:flutter_application_3/models/kendaraan.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class KendaraanPage extends StatelessWidget {
  const KendaraanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kendaraan'),
        ),
        body: const KendaraanBody(),
      ),
    );
  }
}

class KendaraanBody extends StatefulWidget {
  const KendaraanBody({super.key});

  @override
  _KendaraanBodyState createState() => _KendaraanBodyState();
}

class _KendaraanBodyState extends State<KendaraanBody> {
  TextEditingController searchController = TextEditingController();
  List<Kendaraan> filteredKendaraan = [];

  @override
  void initState() {
    super.initState();
    // Fetch karyawan data when the page is initialized
    Future.delayed(Duration.zero, () {
      // Fetch data hanya jika belum ada data
      if (Provider.of<MasterdataProvider>(context, listen: false)
          .kegiatans
          .isEmpty) {
        Provider.of<MasterdataProvider>(context, listen: false)
            .fetchKendaraans();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredKendaraan =
          Provider.of<MasterdataProvider>(context, listen: false)
              .kendaraans
              .where((kendaraan) {
        return kendaraan.kodeVhc.toLowerCase().contains(query.toLowerCase()) ||
            kendaraan.detailvhc.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredKendaraan selalu menggunakan data yang sudah difilter
        filteredKendaraan =
            filteredKendaraan.isEmpty ? provider.kendaraans : filteredKendaraan;

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
            if (filteredKendaraan.isEmpty)
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
                          DataColumn(label: Text("Kode")),
                          DataColumn(label: Text("Unit")),
                        ],
                        rows: List.generate(filteredKendaraan.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(filteredKendaraan[index].kodeVhc)),
                            DataCell(Text(filteredKendaraan[index].detailvhc)),
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
