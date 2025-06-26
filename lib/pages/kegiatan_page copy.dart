import 'package:flutter/material.dart';

class KegiatanPage extends StatefulWidget {
  const KegiatanPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KegiatanPageState createState() => _KegiatanPageState();
}

class _KegiatanPageState extends State<KegiatanPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> kegiatan = [
    {
      "kode": "128010105",
      "kegiatan": "MERATAKAN TANAH",
      "satuan": "PKK",
      "kelompok": "BBT",
    },
    {
      "kode": "128010106",
      "kegiatan": "PEMBUATAN NOMOR BLOK",
      "satuan": "PKK",
      "kelompok": "BBT",
    },
    {
      "kode": "128010107",
      "kegiatan": "PUTAR BABYBAG",
      "satuan": "PKK",
      "kelompok": "BBT",
    },
  ];

  List<Map<String, String>> filteredkegiatan = [];

  @override
  void initState() {
    super.initState();
    filteredkegiatan = List.from(kegiatan);
  }

  void filterSearch(String query) {
    setState(() {
      filteredkegiatan = kegiatan.where((kegiatan) {
        return kegiatan["kode"]!.toLowerCase().contains(query.toLowerCase()) ||
            kegiatan["kegiatan"]!.toLowerCase().contains(query.toLowerCase()) ||
            kegiatan["satuan"]!.toLowerCase().contains(query.toLowerCase()) ||
            kegiatan["kelompok"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kegiatan"),
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
                    DataColumn(label: Text("Kode")),
                    DataColumn(label: Text("Kegiatan")),
                    DataColumn(label: Text("Satuan")),
                    DataColumn(label: Text("Kelompok")),
                  ],
                  rows: List.generate(filteredkegiatan.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredkegiatan[index]["kode"]!)),
                      DataCell(Text(filteredkegiatan[index]["kegiatan"]!)),
                      DataCell(Text(filteredkegiatan[index]["satuan"]!)),
                      DataCell(Text(filteredkegiatan[index]["kelompok"]!))
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
