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
    print('Columns recebidas: ${widget.columns}');
    final totalRows = widget.data.length;
    final start = _page * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, totalRows);
    final pageData = widget.data.sublist(start, end);

    final showActions = widget.onEdit != null || widget.onDelete != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalColumns = widget.columns.length + (showActions ? 1 : 0);
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
                  headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return const Color(0xFF9FCA86);
                    },
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return Colors.white;
                    },
                  ),
                  columns: [
                    ...widget.columns.map(
                      (c) => DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Text(
                            c,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showActions)
                      DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: const Text(
                            'Ações',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                  rows: pageData.map((item) {
                    final cells = <DataCell>[
                      ...widget.buildCells(item),
                    ];
                    if (showActions) {
                      cells.add(
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.onEdit != null)
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFFA67F00)),
                                onPressed: () => widget.onEdit!(item),
                              ),
                            if (widget.onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color.fromARGB(255, 160, 41, 33)),
                                onPressed: () => widget.onDelete!(item),
                              ),
                          ],
                        )),
                      );
                    }
                    return DataRow(cells: cells);
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
                Text(
                    'Página ${_page + 1} de ${((totalRows - 1) ~/ widget.rowsPerPage) + 1}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      end < totalRows ? () => setState(() => _page++) : null,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
