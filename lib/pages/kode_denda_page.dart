import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/kodedendapanen.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class KodedendaPage extends StatelessWidget {
  const KodedendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kode Denda'),
        ),
        body: const KodeDendaBody(),
      ),
    );
  }
}

class KodeDendaBody extends StatefulWidget {
  const KodeDendaBody({super.key});

  @override
  _KodeDendaBodyState createState() => _KodeDendaBodyState();
}

class _KodeDendaBodyState extends State<KodeDendaBody> {
  TextEditingController searchController = TextEditingController();
  List<KodeDendaPanen> filteredKkodedenda = [];

  @override
  void initState() {
    super.initState();
    // Fetch karyawan data when the page is initialized
    Future.delayed(Duration.zero, () {
      // Fetch data hanya jika belum ada data
      if (Provider.of<MasterdataProvider>(context, listen: false)
          .kodedendas
          .isEmpty) {
        Provider.of<MasterdataProvider>(context, listen: false)
            .fetchKodedendas();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredKkodedenda =
          Provider.of<MasterdataProvider>(context, listen: false)
              .kodedendas
              .where((kodedenda) {
        return kodedenda.kodedenda
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            kodedenda.deskripsi.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredKkodedenda selalu menggunakan data yang sudah difilter
        filteredKkodedenda = filteredKkodedenda.isEmpty
            ? provider.kodedendas
            : filteredKkodedenda;

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
            if (filteredKkodedenda.isEmpty)
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
                          DataColumn(label: Text("Kode Denda")),
                          DataColumn(label: Text("Deskripsi")),
                        ],
                        rows: List.generate(filteredKkodedenda.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(Text(filteredKkodedenda[index].kodedenda)),
                            DataCell(Text(filteredKkodedenda[index].deskripsi)),
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
