import 'package:fiap_farms_app/presentation/widgets/generic_table/generic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiap_farms_app/core/providers/venda_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/presentation/widgets/venda_form.dart';

class VendaPage extends ConsumerStatefulWidget {
  const VendaPage({super.key});

  @override
  ConsumerState<VendaPage> createState() => _VendaPageState();
}

class _VendaPageState extends ConsumerState<VendaPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
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

  void _abrirFormulario(BuildContext context, [Venda? venda]) {
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
            child: VendaForm(
              existing: venda,
              onSuccess: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _excluirVenda(Venda venda) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir Venda"),
        content: const Text("Tem certeza que deseja excluir esta venda?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir")),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(vendaRepositoryProvider).deleteVenda(venda);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendasAsync = ref.watch(vendaListStreamProvider);
    final produtoMapaAsync = ref.watch(produtoMapProvider);
    final fazendaMapaAsync = ref.watch(fazendaMapProvider);
    final safraMapaAsync = ref.watch(safraMapProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Vendas',
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
          onPressed: () => _abrirFormulario(context),
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
            vendasAsync.when(
              data: (vendas) {
                if (vendas.isEmpty)
                  return const Center(child: Text('Nenhuma venda registrada.'));

                return produtoMapaAsync.when(
                  data: (produtoMap) => fazendaMapaAsync.when(
                    data: (fazendaMap) => safraMapaAsync.when(
                      data: (safraMap) {
                        final dados = vendas.map((venda) {
                          final item =
                              venda.itens.isNotEmpty ? venda.itens.first : null;
                          final produto = item != null
                              ? produtoMap[item.produtoId] ?? item.produtoId
                              : 'N/A';
                          final quantidade = item?.quantidade ?? 0;
                          final fazenda = item?.fazendaId != null
                              ? (fazendaMap[item!.fazendaId!] ??
                                  item.fazendaId!)
                              : '-';
                          final safra = item?.safraId != null
                              ? (safraMap[item!.safraId!] ?? item.safraId!)
                              : '-';
                          final data =
                              venda.data.toLocal().toString().split(' ')[0];

                          return {
                            'venda': venda,
                            'produto': produto,
                            'quantidade': quantidade,
                            'safra': safra,
                            'fazenda': fazenda,
                            'data': data,
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
                                      data: dados,
                                      buildCells: (item) => [
                                        DataCell(Text(item['produto'])),
                                        DataCell(Text('${item['quantidade']}')),
                                        DataCell(Text(item['safra'])),
                                        DataCell(Text(item['fazenda'])),
                                        DataCell(Text(item['data'])),
                                      ],
                                      onEdit: (item) => _abrirFormulario(
                                          context, item['venda']),
                                      onDelete: (item) =>
                                          _excluirVenda(item['venda']),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Erro safras: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro fazendas: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erro produtos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erro ao carregar vendas: $e')),
      ),
          ],
        ) 
    );
  }
}
