import 'package:fiap_farms_app/presentation/widgets/generic_table/generic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/safra_provider.dart';
import '../widgets/safra_form.dart';
import '../../domain/entities/safra.dart';

class SafraPage extends ConsumerStatefulWidget {
  const SafraPage({super.key});

  @override
  ConsumerState<SafraPage> createState() => _SafraPageState();
}

class _SafraPageState extends ConsumerState<SafraPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _openForm(BuildContext context, {Safra? safra}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF59734A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SafeArea(
            top: false,
            child: SafraForm(existing: safra),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Safra s) async {
    final repo = ref.read(safraRepositoryProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir safra'),
        content: Text('Deseja excluir "${s.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm == true) await repo.deleteSafra(s.id);
  }

  @override
  Widget build(BuildContext context) {
    final safrasAsync = ref.watch(safraListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safras',
          style: TextStyle(
            color: Color(0xFF97133E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF1EBD9),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color.fromARGB(255, 245, 232, 188),
                Color(0xFFF2EDDD),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF59734A),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF2EDDD),
                  Color(0xFFE2C772),
                ],
              ),
            ),
          ),
          // Page content
          safrasAsync.when(
        data: (safras) {
          if (safras.isEmpty) {
                return const Center(child: Text("Nenhuma safra cadastrada."));
          }

          return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: CustomPaginatedTable<Safra>(
                            columns: const ['Nome', 'Valor'],
                            data: safras,
                            buildCells: (s) => [
                              DataCell(Text(s.nome)),
                              DataCell(Text(
                                  '${double.tryParse(s.valor)?.toStringAsFixed(2) ?? s.valor}')),
                            ],
                            onEdit: (s) => _openForm(context, safra: s),
                            onDelete: (s) => _confirmDelete(context, s),
                          ),
                        ),
                      ),
                    ),
                  );
                },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
          ),
        ],
      ),
    );
  }
}
