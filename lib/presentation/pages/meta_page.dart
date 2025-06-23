import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/meta_provider.dart';
import '../../domain/entities/meta.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/fazenda.dart';
import '../../domain/entities/safra.dart';
import '../widgets/meta_form.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/fazenda_provider.dart';
import '../../core/providers/safra_provider.dart';

class MetaPage extends ConsumerWidget {
  const MetaPage({super.key});

  void _abrirForm(BuildContext ctx, {Meta? meta}) {
    showModalBottomSheet(
    context: ctx,
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
          child: MetaForm(existingMeta: meta),
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final metasAsync = ref.watch(metaListStreamProvider);
    final produtosAsync = ref.watch(productListStreamProvider);
    final safraAsync = ref.watch(safraListStreamProvider);
    final fazendaAsync = ref.watch(fazendaListStreamProvider);
    final repo = ref.read(metaRepositoryProvider);

    const Map<String, String> tiposTraduzidos = {
      'producao': 'Produção',
      'venda': 'Venda',
      'vendas': 'Vendas',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(ctx),
        child: const Icon(Icons.add),
      ),
      body: metasAsync.when(
        data: (metas) {
          if (metas.isEmpty) {
            return const Center(child: Text('Nenhuma meta cadastrada.'));
          }
          return produtosAsync.when(
            data: (prods) => safraAsync.when(
              data: (safras) => fazendaAsync.when(
                data: (fazendas) => ListView.builder(
                  itemCount: metas.length,
                  itemBuilder: (_, i) {
                    final meta = metas[i];

                    final prodNome = prods.firstWhere(
                      (p) => p.id == meta.produto,
                      orElse: () => Product(id: meta.produto, nome: 'Prod. não encontrado'),
                    ).nome;

                    final safraNome = safras.firstWhere(
                      (s) => s.id == meta.safra,
                      orElse: () => Safra(id: meta.safra, nome: 'Safra não encontrada', valor: ''),
                    ).nome;

                    final fazendaNome = fazendas.firstWhere(
                      (f) => f.id == meta.fazenda,
                      orElse: () => Fazenda(id: meta.fazenda, nome: 'Fazenda não encontrada', estado: '', latitude: 0, longitude: 0),
                    ).nome;

                    return ListTile(
                      title: Text('${tiposTraduzidos[meta.tipo.toLowerCase()] ?? meta.tipo}: $prodNome'),
                      subtitle: Text('Meta: ${meta.valor} | Safra: $safraNome | Fazenda: $fazendaNome'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _abrirForm(ctx, meta: meta),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await repo.deleteMeta(meta.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro fazendas: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro safras: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro produtos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro metas: $e')),
      ),
    );
  }
}
