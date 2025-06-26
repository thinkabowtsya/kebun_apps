import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/karyawan.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class KaryawanPage extends StatelessWidget {
  const KaryawanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Karyawan'),
        ),
        body: const KaryawanBody(),
      ),
    );
  }
}

class KaryawanBody extends StatefulWidget {
  const KaryawanBody({super.key});

  @override
  _KaryawanBodyState createState() => _KaryawanBodyState();
}

class _KaryawanBodyState extends State<KaryawanBody> {
  TextEditingController searchController = TextEditingController();
  List<Karyawan> filteredKaryawan = [];

  @override
  void initState() {
    super.initState();
    // Fetch karyawan data when the page is initialized
    Future.delayed(Duration.zero, () {
      // Fetch data hanya jika belum ada data
      if (Provider.of<MasterdataProvider>(context, listen: false)
          .karyawans
          .isEmpty) {
        Provider.of<MasterdataProvider>(context, listen: false)
            .fetchKaryawans();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredKaryawan = Provider.of<MasterdataProvider>(context, listen: false)
          .karyawans
          .where((karyawan) {
        // Pencarian berdasarkan nama, nik, dan subbagian
        return karyawan.namakaryawan
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            karyawan.nik.toLowerCase().contains(query.toLowerCase()) ||
            karyawan.subbagian.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredKaryawan selalu menggunakan data yang sudah difilter
        filteredKaryawan =
            filteredKaryawan.isEmpty ? provider.karyawans : filteredKaryawan;

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
            if (filteredKaryawan.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                          DataColumn(label: Text("Nama")),
                          DataColumn(label: Text("NIK")),
                          DataColumn(label: Text("Unit")),
                          DataColumn(label: Text("Afdeling")),
                        ],
                        rows: List.generate(filteredKaryawan.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(
                                Text(filteredKaryawan[index].namakaryawan)),
                            DataCell(Text(filteredKaryawan[index].nik)),
                            DataCell(Text(
                                filteredKaryawan[index].subbagian.length >= 4
                                    ? filteredKaryawan[index]
                                        .subbagian
                                        .substring(0, 4)
                                    : '')), // Cek panjang sebelum substring
                            DataCell(Text(
                                filteredKaryawan[index].subbagian.length >= 6
                                    ? filteredKaryawan[index]
                                        .subbagian
                                        .substring(4, 6)
                                    : '')), // Cek panjang sebelum substring
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
