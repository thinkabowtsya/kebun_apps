import 'package:flutter/material.dart';

class TphPage extends StatefulWidget {
  const TphPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TphPageState createState() => _TphPageState();
}

class _TphPageState extends State<TphPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> tph = [
    {
      "unit": "KTJE",
      "afdeling": "KTJE01",
      "blok": "AA01",
      "tph": "",
      "luas": "",
    },
    {
      "unit": "KTJE",
      "afdeling": "KTJE01",
      "blok": "AA01",
      "tph": "",
      "luas": "",
    },
    {
      "unit": "KTJE",
      "afdeling": "KTJE01",
      "blok": "AA01",
      "tph": "",
      "luas": "",
    },
  ];

  List<Map<String, String>> filteredtph = [];

  @override
  void initState() {
    super.initState();
    filteredtph = List.from(tph);
  }

  void filterSearch(String query) {
    setState(() {
      filteredtph = tph.where((tph) {
        return tph["unit"]!.toLowerCase().contains(query.toLowerCase()) ||
            tph["afdeling"]!.toLowerCase().contains(query.toLowerCase()) ||
            tph["blok"]!.toLowerCase().contains(query.toLowerCase()) ||
            tph["tph"]!.toLowerCase().contains(query.toLowerCase()) ||
            tph["luas"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TPH"),
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
                    DataColumn(label: Text("TPH")),
                    DataColumn(label: Text("Luas")),
                  ],
                  rows: List.generate(filteredtph.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredtph[index]["unit"]!)),
                      DataCell(Text(filteredtph[index]["afdeling"]!)),
                      DataCell(Text(filteredtph[index]["blok"]!)),
                      DataCell(Text(filteredtph[index]["tph"]!)),
                      DataCell(Text(filteredtph[index]["luas"]!)),
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
