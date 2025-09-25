import 'package:flutter/material.dart';

typedef CellBuilder = DataCell Function(
  Map<String, dynamic> row,
  BuildContext context,
);

typedef BottomSheetActionsBuilder = List<Map<String, dynamic>> Function(
  Map<String, dynamic> row,
  BuildContext context,
);

class CustomDataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final Map<String, String>? labelMapping;
  final List<String>? totalColumns;
  final Map<String, CellBuilder>? columnRenderers;

  final bool enableBottomSheet;
  final List<Map<String, dynamic>>? bottomSheetActions;
  final BottomSheetActionsBuilder? bottomSheetActionsBuilder;

  /// Tentukan apakah row sudah tersinkron; jika true → hanya tampil "View"
  final bool Function(Map<String, dynamic> row)? isRowSynced;

  /// Tinggi baris (default = 56). Bisa diset dari luar.
  final double? rowHeight;

  const CustomDataTableWidget({
    super.key,
    required this.data,
    required this.columns,
    this.labelMapping,
    this.totalColumns,
    this.columnRenderers,
    this.enableBottomSheet = false,
    this.bottomSheetActions,
    this.bottomSheetActionsBuilder,
    this.isRowSynced,
    this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    final hasTotal = totalColumns != null && totalColumns!.isNotEmpty;
    final effectiveRowHeight =
        rowHeight ?? (columns.contains('photo') ? 80.0 : 32);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        border: TableBorder.all(color: Colors.grey),
        headingRowColor: WidgetStateProperty.all(Colors.blueGrey[700]),
        headingTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dataRowHeight: effectiveRowHeight,
        headingRowHeight: 40,
        columns: columns
            .map((col) => DataColumn(label: Text(labelMapping?[col] ?? col)))
            .toList(),
        rows: data.isEmpty
            ? [
                DataRow(
                  // penting: tetap punya jumlah cell = columns.length
                  cells: [
                    const DataCell(
                      Center(
                        child: Text(
                          'Data kosong',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(
                      columns.length - 1,
                      (_) => const DataCell(Text('')),
                    ),
                  ],
                )
              ]
            : [
                ...data.map((row) {
                  return DataRow(
                    // === INI YANG HILANG: tap handler buat buka bottom sheet ===
                    onSelectChanged: (_) {
                      if (!enableBottomSheet) return;

                      // Ambil actions: builder > static list
                      final baseActions = bottomSheetActionsBuilder != null
                          ? bottomSheetActionsBuilder!(row, context)
                          : (bottomSheetActions ?? <Map<String, dynamic>>[]);

                      // Filter jika sudah sync → hanya "View"
                      List<Map<String, dynamic>> actions = baseActions;
                      final synced = isRowSynced?.call(row) ?? false;
                      if (synced) {
                        actions = baseActions.where((a) {
                          final key = (a['key'] ?? '').toString().toLowerCase();
                          final label =
                              (a['label'] ?? '').toString().toLowerCase();
                          return key == 'view' || label == 'view';
                        }).toList();
                      }

                      if (actions.isEmpty) return;

                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: Wrap(
                              children: actions
                                  .map<Widget>(
                                    (action) => ListTile(
                                      leading: action['icon'] != null
                                          ? Icon(
                                              action['icon'],
                                              color: action['colors'],
                                            )
                                          : null,
                                      title: Text(action['label'] ?? ''),
                                      onTap: () {
                                        Navigator.pop(context);
                                        final onTap = action['onTap'];
                                        if (onTap != null) onTap(row);
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                      );
                    },
                    cells: columns.map((col) {
                      if (columnRenderers != null &&
                          columnRenderers!.containsKey(col)) {
                        return columnRenderers![col]!(row, context);
                      }
                      return DataCell(Text(row[col]?.toString() ?? ''));
                    }).toList(),
                  );
                }),
                if (hasTotal)
                  DataRow(
                    color: WidgetStateProperty.all(Colors.grey[300]),
                    cells: columns.map((col) {
                      if (col == columns.first) {
                        return const DataCell(
                          Text('TOTAL',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        );
                      } else if (totalColumns!.contains(col)) {
                        final total = data.fold<num>(
                          0,
                          (sum, item) =>
                              sum +
                              (num.tryParse(item[col]?.toString() ?? '0') ?? 0),
                        );
                        return DataCell(
                          Text(
                            total.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      } else {
                        return const DataCell(Text('-'));
                      }
                    }).toList(),
                  ),
              ],
      ),
    );
  }
}
