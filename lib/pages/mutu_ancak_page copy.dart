import 'package:flutter/material.dart';

class MutuAncakPage extends StatefulWidget {
  const MutuAncakPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MutuAncakPageState createState() => _MutuAncakPageState();
}

class _MutuAncakPageState extends State<MutuAncakPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> mutuancak = [
    {
      "kodemutu": "NP",
      "nama": "Normal Produktif",
      "satuan": "np",
    },
    {
      "kodemutu": "S",
      "nama": "Sisip",
      "satuan": "jjg",
    },
    {
      "kodemutu": "SK",
      "nama": "Sakit",
      "satuan": "jjg",
    },
    
    
  ];

  List<Map<String, String>> filteredmutuancak = [];

  @override
  void initState() {
    super.initState();
    filteredmutuancak = List.from(mutuancak);
  }

  void filterSearch(String query) {
    setState(() {
      filteredmutuancak = mutuancak.where((mutuancak) {
        return mutuancak["kodemutu"]!.toLowerCase().contains(query.toLowerCase()) ||
            mutuancak["nama"]!.toLowerCase().contains(query.toLowerCase()) ||
            mutuancak["satuan"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mutu Ancak"),
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
                    DataColumn(label: Text("Kode Mutu")),
                    DataColumn(label: Text("Nama")),
                    DataColumn(label: Text("Satuan")),
                  ],
                  rows: List.generate(filteredmutuancak.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredmutuancak[index]["kodemutu"]!)),
                      DataCell(Text(filteredmutuancak[index]["nama"]!)),
                      DataCell(Text(filteredmutuancak[index]["satuan"]!)),
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
