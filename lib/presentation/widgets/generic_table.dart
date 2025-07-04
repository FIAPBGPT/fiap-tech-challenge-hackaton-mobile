import 'package:flutter/material.dart';

class CustomPaginatedTable<T> extends StatefulWidget {
  final List<String> columns;
  final List<T> data;
  final List<DataCell> Function(T) buildCells;
  final void Function(T)? onEdit;
  final void Function(T)? onDelete;
  final int rowsPerPage;

  const CustomPaginatedTable({
    super.key,
    required this.columns,
    required this.data,
    required this.buildCells,
    this.onEdit,
    this.onDelete,
    this.rowsPerPage = 5,
  });

  @override
  State<CustomPaginatedTable<T>> createState() =>
      _CustomPaginatedTableState<T>();
}

class _CustomPaginatedTableState<T> extends State<CustomPaginatedTable<T>> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final totalRows = widget.data.length;
    final start = _page * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, totalRows);
    final pageData = widget.data.sublist(start, end);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalColumns = widget.columns.length + 1; // +1 para 'Ações'
        const baseSpacing = 16.0;

        double columnSpacing = (availableWidth - 32) / totalColumns - baseSpacing;
        if (columnSpacing < 16) columnSpacing = 16;
        if (columnSpacing > 120) columnSpacing = 120;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: availableWidth),
                child: DataTable(
                  columnSpacing: columnSpacing,
                  columns: [
                    ...widget.columns.map((c) => DataColumn(label: Text(c))),
                    const DataColumn(label: Text('Ações')),
                  ],
                  rows: pageData.map((item) {
                    return DataRow(
                      cells: [
                        ...widget.buildCells(item),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.onEdit != null)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => widget.onEdit!(item),
                              ),
                            if (widget.onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => widget.onDelete!(item),
                              ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _page > 0 ? () => setState(() => _page--) : null,
                ),
                Text('Página ${_page + 1} de ${((totalRows - 1) ~/ widget.rowsPerPage) + 1}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: end < totalRows ? () => setState(() => _page++) : null,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
