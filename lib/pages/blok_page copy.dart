import 'package:flutter/material.dart';

class BlokPage extends StatefulWidget {
  const BlokPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BlokPageState createState() => _BlokPageState();
}

class _BlokPageState extends State<BlokPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> blok = [
    {
      "unit": "KTJE",
      "afdeling": "KTJE01",
      "blok": "0",
      "tt": "0",
      "luas": "3500",
      "sph": "3500",
      "pokok": "3500"
    },
    {
      "unit": "KTJE",
      "afdeling": "KTJE01",
      "blok": "0",
      "tt": "0",
      "luas": "3500",
      "sph": "3500",
      "pokok": "3500"
    },
    {
      "unit": "KTJE",
      "afdeling": "KTJE01",
      "blok": "0",
      "tt": "0",
      "luas": "3500",
      "sph": "3500",
      "pokok": "3500"
    },
  ];

  List<Map<String, String>> filteredblok = [];

  @override
  void initState() {
    super.initState();
    filteredblok = List.from(blok);
  }

  void filterSearch(String query) {
    setState(() {
      filteredblok = blok.where((blok) {
        return blok["unit"]!.toLowerCase().contains(query.toLowerCase()) ||
            blok["afdeling"]!.toLowerCase().contains(query.toLowerCase()) ||
            blok["blok"]!.toLowerCase().contains(query.toLowerCase()) ||
            blok["tt"]!.toLowerCase().contains(query.toLowerCase()) ||
            blok["luas"]!.toLowerCase().contains(query.toLowerCase()) ||
            blok["sph"]!.toLowerCase().contains(query.toLowerCase()) ||
            blok["pokok"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blok"),
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
                    DataColumn(label: Text("Unit")),
                    DataColumn(label: Text("Afdeling")),
                    DataColumn(label: Text("Blok")),
                    DataColumn(label: Text("TT")),
                    DataColumn(label: Text("Luas")),
                    DataColumn(label: Text("SPH")),
                    DataColumn(label: Text("Pokok")),
                  ],
                  rows: List.generate(filteredblok.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredblok[index]["unit"]!)),
                      DataCell(Text(filteredblok[index]["afdeling"]!)),
                      DataCell(Text(filteredblok[index]["blok"]!)),
                      DataCell(Text(filteredblok[index]["tt"]!)),
                      DataCell(Text(filteredblok[index]["luas"]!)),
                      DataCell(Text(filteredblok[index]["sph"]!)),
                      DataCell(Text(filteredblok[index]["pokok"]!)),
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
