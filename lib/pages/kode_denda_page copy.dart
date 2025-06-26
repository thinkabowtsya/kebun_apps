import 'package:flutter/material.dart';

class KodeDendaPage extends StatefulWidget {
  const KodeDendaPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KodeDendaPageState createState() => _KodeDendaPageState();
}

class _KodeDendaPageState extends State<KodeDendaPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> kodedenda = [
    {
      "kodedenda": "BM",
      "deskripsi": "Panen buah mentah",
    },
    {
      "kodedenda": "BMT",
      "deskripsi": "Buah masak tidak dipanen",
    },
    {
      "kodedenda": "BMA",
      "deskripsi": "Buah mentah diperam diancak",
    },
    
  ];

  List<Map<String, String>> filteredkodedenda = [];

  @override
  void initState() {
    super.initState();
    filteredkodedenda = List.from(kodedenda);
  }

  void filterSearch(String query) {
    setState(() {
      filteredkodedenda = kodedenda.where((kodedenda) {
        return kodedenda["kode"]!.toLowerCase().contains(query.toLowerCase()) ||
            kodedenda["unit"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kode Denda"),
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
                    DataColumn(label: Text("Kode Denda")),
                    DataColumn(label: Text("Deskripsi")),
                  ],
                  rows: List.generate(filteredkodedenda.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredkodedenda[index]["kodedenda"]!)),
                      DataCell(Text(filteredkodedenda[index]["deskripsi"]!)),
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
