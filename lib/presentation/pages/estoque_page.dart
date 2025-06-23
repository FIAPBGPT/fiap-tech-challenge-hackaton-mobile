import 'package:fiap_farms_app/domain/entities/estoque.dart';
import 'package:fiap_farms_app/presentation/widgets/estoque_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/estoque_provider.dart';
import '../../core/providers/product_provider.dart';

class EstoquePage extends ConsumerStatefulWidget {
  const EstoquePage({super.key});

  @override
  ConsumerState<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends ConsumerState<EstoquePage> {
  Estoque? estoqueEditando;

  void _abrirForm(BuildContext context, [Estoque? estoque]) {
    setState(() {
      estoqueEditando = estoque;
    });

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
            child: EstoqueForm(
              existing: estoqueEditando,
              onSuccess: () {
                Navigator.pop(context);
                setState(() {
                  estoqueEditando = null;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _excluirEstoque(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir Registro de Estoque"),
        content: const Text("Tem certeza que deseja excluir este item do estoque?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Excluir")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(estoqueRepositoryProvider).excluirEstoque(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item excluído com sucesso.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao excluir: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final estoqueAsync = ref.watch(estoqueListStreamProvider);
    final produtoMapaAsync = ref.watch(produtoMapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estoque')),
      body: estoqueAsync.when(
        data: (estoques) {
          if (estoques.isEmpty) {
            return const Center(child: Text('Nenhum registro de estoque.'));
          }

          return produtoMapaAsync.when(
            data: (produtoMapa) {
              return ListView.builder(
                itemCount: estoques.length,
                itemBuilder: (context, index) {
                  final e = estoques[index];
                  final nomeProduto = produtoMapa[e.produtoId] ?? e.produtoId;

                  return ListTile(
                    title: Text(nomeProduto),
                    subtitle: Text(
                      'Qtd: ${e.quantidade} | Tipo: ${e.tipo}\n'
                      'Safra: ${e.safraId ?? "-"} | Fazenda: ${e.fazendaId ?? "-"}\n'
                      'Data: ${e.data.toLocal().toString().split(' ')[0]}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _abrirForm(context, e),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluirEstoque(context, ref, e.id),
                        ),
                      ],
                    ),
                    onTap: () => _abrirForm(context, e), // Também permite editar clicando
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar produtos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar estoque: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(context),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Estoque',
      ),
    );
  }
}
