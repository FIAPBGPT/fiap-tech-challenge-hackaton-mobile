import 'package:fiap_farms_app/presentation/widgets/generic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class MetaPage extends ConsumerStatefulWidget {
  const MetaPage({super.key});

  @override
  ConsumerState<MetaPage> createState() => _MetaPageState();
}

class _MetaPageState extends ConsumerState<MetaPage> {
  @override
  void initState() {
    super.initState();
    // 👉 Força orientação paisagem ao entrar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // 👉 Restaura orientação retrato ao sair
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

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
  Widget build(BuildContext ctx) {
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
                data: (fazendas) {
                  final metasComDados = metas.map((meta) {
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

                    return {
                      'meta': meta,
                      'tipo':
                          tiposTraduzidos[meta.tipo.toLowerCase()] ?? meta.tipo,
                      'produto': prodNome,
                      'valor': meta.valor,
                      'safra': safraNome,
                      'fazenda': fazendaNome,
                    };
                  }).toList();

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomPaginatedTable<Map<String, dynamic>>(
                      columns: const [
                        'Tipo',
                        'Produto',
                        'Meta',
                        'Safra',
                        'Fazenda'
                      ],
                      data: metasComDados,
                      buildCells: (item) => [
                        DataCell(Text(item['tipo'])),
                        DataCell(Text(item['produto'])),
                        DataCell(Text(item['valor'].toString())),
                        DataCell(Text(item['safra'])),
                        DataCell(Text(item['fazenda'])),
                      ],
                      onEdit: (item) => _abrirForm(ctx, meta: item['meta']),
                      onDelete: (item) async =>
                          await repo.deleteMeta(item['meta'].id),
                    ),
                  );
                },
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
