import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/fazenda_provider.dart';
import '../widgets/fazenda_form.dart';
import '../../domain/entities/fazenda.dart';

class FazendaPage extends ConsumerWidget {
  const FazendaPage({super.key});

  void _openForm(BuildContext context, {Fazenda? fazenda}) {
     showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fazendasAsync = ref.watch(fazendaListStreamProvider);
    final repo = ref.read(fazendaRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: fazendasAsync.when(
          data: (fazendas) {
            if (fazendas.isEmpty) return const Center(child: Text("Nenhuma fazenda cadastrada."));
            return ListView.builder(
              itemCount: fazendas.length,
              itemBuilder: (_, index) {
                final f = fazendas[index];
                return ListTile(
                  title: Text(f.nome),
                  subtitle: Text('${f.estado} • Lat: ${f.latitude}, Long: ${f.longitude}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(context, fazenda: f)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir fazenda'),
                              content: Text('Deseja realmente excluir "${f.nome}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                              ],
                            ),
                          );
                          if (confirm == true) await repo.deleteFazenda(f.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
        ),
      ),
    );
  }
}
