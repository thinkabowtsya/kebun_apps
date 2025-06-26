import 'package:flutter/material.dart';

class KendaraanPage extends StatefulWidget {
  const KendaraanPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KendaraanPageState createState() => _KendaraanPageState();
}

class _KendaraanPageState extends State<KendaraanPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> kendaraan = [
    {
      "kode": "KTJE01",
      "unit": "KTJE",
    },
    {
      "kode": "KTJE02",
      "unit": "KTJE",
    },
    {
      "kode": "KTJE03",
      "unit": "KTJE",
    },
    {
      "kode": "KTJE04",
      "unit": "KTJE",
    },
  ];

  List<Map<String, String>> filteredkendaraan = [];

  @override
  void initState() {
    super.initState();
    filteredkendaraan = List.from(kendaraan);
  }

  void filterSearch(String query) {
    setState(() {
      filteredkendaraan = kendaraan.where((kendaraan) {
        return kendaraan["kode"]!.toLowerCase().contains(query.toLowerCase()) ||
            kendaraan["unit"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kendaraan"),
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
                    DataColumn(label: Text("Unit")),
                  ],
                  rows: List.generate(filteredkendaraan.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredkendaraan[index]["kode"]!)),
                      DataCell(Text(filteredkendaraan[index]["unit"]!)),
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
