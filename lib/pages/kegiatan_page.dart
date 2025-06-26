import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/kegiatan.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class KegiatanPage extends StatelessWidget {
  const KegiatanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kegiatan'),
        ),
        body: const KegiatanBody(),
      ),
    );
  }
}

class KegiatanBody extends StatefulWidget {
  const KegiatanBody({super.key});

  @override
  _KegiatanBodyState createState() => _KegiatanBodyState();
}

class _KegiatanBodyState extends State<KegiatanBody> {
  TextEditingController searchController = TextEditingController();
  List<Kegiatan> filteredKegiatan = [];

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
            .fetchKegiatans();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredKegiatan = Provider.of<MasterdataProvider>(context, listen: false)
          .kegiatans
          .where((kegiatan) {
        return kegiatan.kodekegiatan
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            kegiatan.namakegiatan.toLowerCase().contains(query.toLowerCase()) ||
            kegiatan.satuan.toLowerCase().contains(query.toLowerCase()) ||
            kegiatan.kelompok.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredKegiatan selalu menggunakan data yang sudah difilter
        filteredKegiatan =
            filteredKegiatan.isEmpty ? provider.kegiatans : filteredKegiatan;

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
            if (filteredKegiatan.isEmpty)
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
                          DataColumn(label: Text("Kegiatan")),
                          DataColumn(label: Text("Satuan")),
                          DataColumn(label: Text("Kelompok")),
                        ],
                        rows: List.generate(filteredKegiatan.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(
                                Text(filteredKegiatan[index].kodekegiatan)),
                            DataCell(
                                Text(filteredKegiatan[index].namakegiatan)),
                            DataCell(Text(filteredKegiatan[index]
                                .satuan)), // Cek panjang sebelum substring
                            DataCell(Text(filteredKegiatan[index]
                                .kelompok)), // Cek panjang sebelum substring
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
