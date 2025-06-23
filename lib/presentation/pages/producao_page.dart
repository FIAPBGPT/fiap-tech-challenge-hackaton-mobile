import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/producao.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/fazenda.dart';
import '../../domain/entities/safra.dart';

import '../../core/providers/producao_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/fazenda_provider.dart';
import '../../core/providers/safra_provider.dart';

import '../widgets/producao_form.dart';

class ProducaoPage extends ConsumerWidget {
  const ProducaoPage({super.key});

  void _abrirForm(BuildContext context, {Producao? producao}) {
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
          child: ProducaoForm(existing: producao),
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final producaoAsync = ref.watch(producaoListStreamProvider);
    final produtosAsync = ref.watch(productListStreamProvider);
    final fazendasAsync = ref.watch(fazendaListStreamProvider);
    final safrasAsync = ref.watch(safraListStreamProvider);
    final repo = ref.read(producaoRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Produções')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(context),
        child: const Icon(Icons.add),
      ),
      body: producaoAsync.when(
        data: (producoes) {
          return produtosAsync.when(
            data: (produtos) {
              return fazendasAsync.when(
                data: (fazendas) {
                  return safrasAsync.when(
                    data: (safras) {
                      if (producoes.isEmpty) {
                        return const Center(child: Text("Nenhuma produção cadastrada."));
                      }

                      return ListView.builder(
                        itemCount: producoes.length,
                        itemBuilder: (_, i) {
                          final p = producoes[i];

                          final produtoNome = produtos.firstWhere(
                            (prod) => prod.id == p.produto,
                            orElse: () => Product(id: p.produto, nome: 'Produto desconhecido'),
                          ).nome;

                          final fazendaNome = fazendas.firstWhere(
                            (f) => f.id == p.fazenda,
                            orElse: () => Fazenda(id: p.fazenda, nome: 'Fazenda desconhecida', estado: '', latitude: 0, longitude: 0),
                          ).nome;

                          final safraNome = safras.firstWhere(
                            (s) => s.id == p.safra,
                            orElse: () => Safra(id: p.safra, nome: 'Safra desconhecida', valor: ''),
                          ).nome;

                          return ListTile(
                            title: Text('Produto: $produtoNome | Quantidade: ${p.quantidade}'),
                            subtitle: Text('Fazenda: $fazendaNome | Safra: $safraNome'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _abrirForm(context, producao: p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => repo.deleteProducao(p.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_box_outlined, color: Colors.green),
                                  tooltip: 'Registrar no estoque',
                                  onPressed: () async {
                                    await repo.registrarProducaoEstoque(p);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Produção registrada no estoque.")),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro nas safras: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro nas fazendas: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro nos produtos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro nas produções: $e')),
      ),
    );
  }
}
