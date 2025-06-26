import 'package:flutter/material.dart';

class KemandoranPage extends StatefulWidget {
  const KemandoranPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KemandoranPageState createState() => _KemandoranPageState();
}

class _KemandoranPageState extends State<KemandoranPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> kemandoran = [
    {
      "kodemandor": "KTJE",
      "namamandor": "KTJE01",
      "namakaryawan": "ARDI",
    },
    {
      "kodemandor": "KTJE",
      "namamandor": "KTJE01",
      "namakaryawan": "ARDI",
    },
    {
      "kodemandor": "KTJE",
      "namamandor": "KTJE01",
      "namakaryawan": "ARDI",
    },
  ];

  List<Map<String, String>> filteredkemandoran = [];

  @override
  void initState() {
    super.initState();
    filteredkemandoran = List.from(kemandoran);
  }

  void filterSearch(String query) {
    setState(() {
      filteredkemandoran = kemandoran.where((kemandoran) {
        return kemandoran["kodemandor"]!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            kemandoran["namamandor"]!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            kemandoran["namakaryawan"]!
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kemandoran"),
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
                    DataColumn(label: Text("Kode Mandor")),
                    DataColumn(label: Text("Nama Mandor")),
                    DataColumn(label: Text("Nama Karyawan")),
                  ],
                  rows: List.generate(filteredkemandoran.length, (index) {
                    return DataRow(cells: [
                      DataCell(Text("${index + 1}")),
                      DataCell(Text(filteredkemandoran[index]["kodemandor"]!)),
                      DataCell(Text(filteredkemandoran[index]["namamandor"]!)),
                      DataCell(Text(filteredkemandoran[index]["namakaryawan"]!)),
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
