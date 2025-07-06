import 'package:fiap_farms_app/presentation/widgets/generic_table/generic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/producao_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/domain/entities/producao.dart';
import 'package:fiap_farms_app/presentation/widgets/producao_form.dart';

class ProducaoPage extends ConsumerStatefulWidget {
  const ProducaoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProducaoPage> createState() => _ProducaoPageState();
}

class _ProducaoPageState extends ConsumerState<ProducaoPage> {
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

  void _abrirForm([Producao? p]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF59734A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: ProducaoForm(producao: p),
        ),
      ),
    );
  }

  Future<void> _excluir(Producao p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Produção'),
        content: const Text('Confirma a exclusão desta produção?'),
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

    if (confirm != true) return;

    try {
      await ref.read(producaoRepositoryProvider).deleteProducao(p);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produção excluída com sucesso.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final producoesAsync = ref.watch(producaoListStreamProvider);
    final fazendaMapAsync = ref.watch(fazendaMapProvider);
    final produtoMapAsync = ref.watch(produtoMapProvider);
    final safraMapAsync = ref.watch(safraMapProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Produção',
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
          onPressed: () => _abrirForm(),
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
            producoesAsync.when(
        data: (producoes) {
          return fazendaMapAsync.when(
            data: (fazendaMap) {
              return produtoMapAsync.when(
                data: (produtoMap) {
                  return safraMapAsync.when(
                    data: (safraMap) {
                      if (producoes.isEmpty) {
                        return const Center(
                            child: Text('Nenhuma produção cadastrada.'));
                      }

                            final producaoDados = producoes.map((p) {
                              return {
                                'producao': p,
                                'produto':
                                    produtoMap[p.produto] ?? p.produto ?? 'N/A',
                                'quantidade': p.quantidade,
                                'safra': safraMap[p.safra] ?? p.safra ?? 'N/A',
                                'fazenda':
                                    fazendaMap[p.fazenda] ?? p.fazenda ?? 'N/A',
                                'data': p.data != null
                                    ? p.data!.toLocal().toString().split(' ')[0]
                                    : 'N/A',
                              };
                            }).toList();

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        child: CustomPaginatedTable<
                                            Map<String, dynamic>>(
                                          columns: const [
                                            'Produto',
                                            'Quantidade',
                                            'Safra',
                                            'Fazenda',
                                            'Data'
                                          ],
                                          data: producaoDados,
                                          buildCells: (item) => [
                                            DataCell(Text(item['produto'])),
                                            DataCell(
                                                Text('${item['quantidade']}')),
                                            DataCell(Text(item['safra'])),
                                            DataCell(Text(item['fazenda'])),
                                            DataCell(Text(item['data'])),
                                          ],
                                          onEdit: (item) =>
                                              _abrirForm(item['producao']),
                                          onDelete: (item) =>
                                              _excluir(item['producao']),
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Erro ao carregar safras: $e')),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Erro ao carregar produtos: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Erro ao carregar fazendas: $e')),
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
