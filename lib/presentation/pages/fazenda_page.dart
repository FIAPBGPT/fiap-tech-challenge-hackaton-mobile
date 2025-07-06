import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/fazenda_provider.dart';
import '../widgets/fazenda_form.dart';
import '../../domain/entities/fazenda.dart';
import '../widgets/generic_table/generic_table.dart';

class FazendaPage extends ConsumerStatefulWidget {
  const FazendaPage({super.key});

  @override
  ConsumerState<FazendaPage> createState() => _FazendaPageState();
}

class _FazendaPageState extends ConsumerState<FazendaPage> {
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

  void _openForm(BuildContext context, {Fazenda? fazenda}) {
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
            child: FazendaForm(existing: fazenda),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Fazenda f) async {
    final repo = ref.read(fazendaRepositoryProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir fazenda'),
        content: Text('Deseja realmente excluir "${f.nome}"?'),
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
    if (confirm == true) await repo.deleteFazenda(f.id);
  }

  @override
  Widget build(BuildContext context) {
    final fazendasAsync = ref.watch(fazendaListStreamProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Fazendas',
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

            fazendasAsync.when(
        data: (fazendas) {
          if (fazendas.isEmpty) {
            return const Center(child: Text("Nenhuma fazenda cadastrada."));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                        width: constraints.maxWidth,
                        child: CustomPaginatedTable<Fazenda>(
                          columns: const [
                            'Nome',
                            'Estado',
                            'Latitude',
                            'Longitude'
                          ],
                          data: fazendas,
                          buildCells: (f) => [
                            DataCell(Text(f.nome)),
                            DataCell(Text(f.estado)),
                            DataCell(Text('${f.latitude}')),
                            DataCell(Text('${f.longitude}')),
                          ],
                          onEdit: (f) => _openForm(context, fazenda: f),
                          onDelete: (f) => _confirmDelete(context, f),
                        )),
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
        )
    );
  }
}
