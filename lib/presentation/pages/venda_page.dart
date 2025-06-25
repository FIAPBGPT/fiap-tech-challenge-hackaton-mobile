// ✅ Módulo: VENDAS - Página semelhante à produção, com exibição de dados, edição e exclusão

import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/core/providers/venda_provider.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/presentation/widgets/venda_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendaPage extends ConsumerWidget {
  const VendaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendasAsync = ref.watch(vendaListStreamProvider);
    final produtoMapaAsync = ref.watch(produtoMapProvider);
    final fazendaMapaAsync = ref.watch(fazendaMapProvider);
    final safraMapaAsync = ref.watch(safraMapProvider);

    void _abrirFormulario([Venda? venda]) {
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
              child: VendaForm(
                existing: venda,
                onSuccess: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vendas')),
      body: vendasAsync.when(
        data: (vendas) {
          if (vendas.isEmpty) {
            return const Center(child: Text('Nenhuma venda registrada.'));
          }

          return produtoMapaAsync.when(
            data: (produtoMap) => fazendaMapaAsync.when(
              data: (fazendaMap) => safraMapaAsync.when(
                data: (safraMap) => ListView.builder(
                  itemCount: vendas.length,
                  itemBuilder: (context, i) {
                    final v = vendas[i];
                    final itensStr = v.itens.map((e) {
                      final nomeProduto =
                          produtoMap[e.produtoId] ?? e.produtoId;
                      final nomeFazenda = e.fazendaId != null
                          ? (fazendaMap[e.fazendaId!] ?? e.fazendaId!)
                          : '-';
                      final nomeSafra = e.safraId != null
                          ? (safraMap[e.safraId!] ?? e.safraId!)
                          : '-';
                      return 'Quantidade: ${e.quantidade}\nSafra: $nomeSafra | Fazenda: $nomeFazenda';
                    }).join('\n\n');

                    final vendaNomeProduto = v.itens.isNotEmpty
                        ? (produtoMap[v.itens.first.produtoId] ??
                            v.itens.first.produtoId)
                        : 'Sem Produto';

                    return ListTile(
                      title: Text('Venda: $vendaNomeProduto'),
                      subtitle: Text(itensStr),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _abrirFormulario(v),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Excluir Venda"),
                                  content: const Text(
                                      "Tem certeza que deseja excluir esta venda?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancelar")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Excluir")),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref
                                    .read(vendaRepositoryProvider)
                                    .deleteVenda(v);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => _abrirFormulario(v),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro safras: \$e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro fazendas: \$e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro produtos: \$e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar vendas: \$e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Venda',
      ),
    );
  }
}
