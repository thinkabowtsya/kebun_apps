import 'package:flutter/material.dart';

class HamaPage extends StatefulWidget {
  const HamaPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HamaPageState createState() => _HamaPageState();
}

class _HamaPageState extends State<HamaPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> hama = [
    {
      "kodehama": "NP",
      "nama": "Normal Produktif",
      "satuan": "np",
    },
    {
      "kodehama": "S",
      "nama": "Sisip",
      "satuan": "jjg",
    },
    {
      "kodehama": "SK",
      "nama": "Sakit",
      "satuan": "jjg",
    },
    
    
  ];

  List<Map<String, String>> filteredhama = [];

  @override
  void initState() {
    super.initState();
    filteredhama = List.from(hama);
  }

  void filterSearch(String query) {
    setState(() {
      filteredhama = hama.where((hama) {
        return hama["kodehama"]!.toLowerCase().contains(query.toLowerCase()) ||
            hama["nama"]!.toLowerCase().contains(query.toLowerCase()) ||
            hama["satuan"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hama"),
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
                    DataColumn(label: Text("Kode Hama")),
                    DataColumn(label: Text("Nama")),
                    DataColumn(label: Text("Satuan")),
                  ],
                  rows: List.generate(filteredhama.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredhama[index]["kodehama"]!)),
                      DataCell(Text(filteredhama[index]["nama"]!)),
                      DataCell(Text(filteredhama[index]["satuan"]!)),
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
