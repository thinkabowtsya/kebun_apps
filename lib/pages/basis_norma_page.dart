import 'package:flutter/material.dart';

class BasisNormaKegiatanPage extends StatefulWidget {
  const BasisNormaKegiatanPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BasisNormaKegiatanPageState createState() => _BasisNormaKegiatanPageState();
}

class _BasisNormaKegiatanPageState extends State<BasisNormaKegiatanPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> basisnormakegiatan = [
    {
      "nama_kegiatan": " ",
      "kode_kegiatan": "220038",
      "tt": "0",
      "basis": "0",
      "extra_fooding": "3500"
    },
    {
      "nama_kegiatan": " ",
      "kode_kegiatan": "5555",
      "tt": "0",
      "basis": "0",
      "extra_fooding": "3500"
    },
  ];

  List<Map<String, String>> filteredbasisnormakegiatan = [];

  @override
  void initState() {
    super.initState();
    filteredbasisnormakegiatan = List.from(basisnormakegiatan);
  }

  void filterSearch(String query) {
    setState(() {
      filteredbasisnormakegiatan =
          basisnormakegiatan.where((basisnormakegiatan) {
        return basisnormakegiatan["nama_kegiatan"]!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            basisnormakegiatan["kode_kegiatan"]!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            basisnormakegiatan["tt"]!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            basisnormakegiatan["basis"]!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            basisnormakegiatan["extra_fooding"]!
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Basis Norma Kegiatan"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Search..",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // SCROLLABLE TABLE
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.grey),
                  headingRowColor:
                      WidgetStateProperty.all(Colors.blueGrey[700]),
                  headingTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  columns: const [
                    DataColumn(label: Text("No")),
                    DataColumn(label: Text("Nama Kegiatan")),
                    DataColumn(label: Text("Kode Kegiatan")),
                    DataColumn(label: Text("TT")),
                    DataColumn(label: Text("Basis")),
                    DataColumn(label: Text("Extra Fooding")),
                  ],
                  rows:
                      List.generate(filteredbasisnormakegiatan.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(
                          filteredbasisnormakegiatan[index]["nama_kegiatan"]!)),
                      DataCell(Text(
                          filteredbasisnormakegiatan[index]["kode_kegiatan"]!)),
                      DataCell(Text(filteredbasisnormakegiatan[index]["tt"]!)),
                      DataCell(
                          Text(filteredbasisnormakegiatan[index]["basis"]!)),
                      DataCell(Text(
                          filteredbasisnormakegiatan[index]["extra_fooding"]!)),
                    ]);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
