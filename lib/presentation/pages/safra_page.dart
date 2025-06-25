import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/safra_provider.dart';
import '../widgets/safra_form.dart';
import '../../domain/entities/safra.dart';

class SafraPage extends ConsumerWidget {
  const SafraPage({super.key});

  void _openForm(BuildContext context, {Safra? safra}) {
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
          child: SafraForm(existing: safra),
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safraAsync = ref.watch(safraListStreamProvider);
    final repo = ref.read(safraRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: safraAsync.when(
          data: (safras) {
            if (safras.isEmpty) return const Center(child: Text("Nenhuma safra cadastrada."));
            return ListView.builder(
              itemCount: safras.length,
              itemBuilder: (_, index) {
                final s = safras[index];
                return ListTile(
                  title: Text(s.nome),
                  subtitle: Text('Valor: ${s.valor}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(context, safra: s)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir safra'),
                              content: Text('Deseja excluir "${s.nome}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                              ],
                            ),
                          );
                          if (confirm == true) await repo.deleteSafra(s.id);
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
