import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/kemandoran.dart';
import 'package:flutter_application_3/models/setuphama.dart';
import 'package:flutter_application_3/models/setupmutu.dart';
import 'package:flutter_application_3/providers/masterdata_provider.dart';
import 'package:provider/provider.dart';

class KemandoranPage extends StatelessWidget {
  const KemandoranPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan MasterdataProvider ke seluruh aplikasi
    return ChangeNotifierProvider(
      create: (context) => MasterdataProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kemandoran'),
        ),
        body: const KemandoranBody(),
      ),
    );
  }
}

class KemandoranBody extends StatefulWidget {
  const KemandoranBody({super.key});

  @override
  _KemandoranBodyState createState() => _KemandoranBodyState();
}

class _KemandoranBodyState extends State<KemandoranBody> {
  TextEditingController searchController = TextEditingController();
  List<Kemandoran> filteredkemandoran = [];

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
            .fetchKemandoran();
      }
    });
  }

  // Fungsi untuk memfilter data karyawan berdasarkan query
  void filterSearch(String query) {
    setState(() {
      filteredkemandoran =
          Provider.of<MasterdataProvider>(context, listen: false)
              .kemandorans
              .where((kemandoran) {
        return kemandoran.mandor.toLowerCase().contains(query.toLowerCase()) ||
            kemandoran.namakaryawan.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterdataProvider>(
      // Memastikan data selalu terupdate
      builder: (context, provider, child) {
        // Pastikan filteredkemandoran selalu menggunakan data yang sudah difilter
        filteredkemandoran = filteredkemandoran.isEmpty
            ? provider.kemandorans
            : filteredkemandoran;

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
            if (filteredkemandoran.isEmpty)
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
                          DataColumn(label: Text("Kode Mandor")),
                          DataColumn(label: Text("Nama Mandor")),
                          DataColumn(label: Text("Nama Karyawan")),
                        ],
                        rows: List.generate(filteredkemandoran.length, (index) {
                          return DataRow(cells: [
                            DataCell(Text("${index + 1}")),
                            DataCell(
                                Text(filteredkemandoran[index].karyawanid)),
                            DataCell(Text(filteredkemandoran[index].mandor)),
                            DataCell(
                                Text(filteredkemandoran[index].namakaryawan)),
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
