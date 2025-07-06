import 'package:fiap_farms_app/presentation/widgets/generic_table/generic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/estoque_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/fazenda_provider.dart';
import '../../core/providers/safra_provider.dart';
import '../../domain/entities/estoque.dart';

class EstoquePage extends ConsumerStatefulWidget {
  const EstoquePage({super.key});

  @override
  ConsumerState<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends ConsumerState<EstoquePage> {
  String? produtoId;
  String? fazendaId;
  String? safraId;
  double saldoAtual = 0;
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _consultarSaldo() async {
    final repo = ref.read(estoqueRepositoryProvider);
    final saldo = await repo.consultarSaldo(
      produtoId: produtoId ?? '',
      safraId: safraId,
      fazendaId: fazendaId,
    );
    setState(() => saldoAtual = saldo);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estoquesAsync = ref.watch(estoqueListStreamProvider);
    final produtoMapaAsync = ref.watch(produtoMapProvider);
    final fazendaMapAsync = ref.watch(fazendaMapProvider);
    final safraMapAsync = ref.watch(safraMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estoque',
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
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF1EBD9),
                Color(0xFFF2EDDD),
              ],
            ),
          ),
        ),
        Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                          child: fazendaMapAsync.when(
                            data: (fazendaMap) =>
                                DropdownButtonFormField<String>(
                              value: fazendaId,
                              decoration:
                                  const InputDecoration(labelText: 'Fazenda'),
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('Todas')),
                                ...fazendaMap.entries.map((e) =>
                                    DropdownMenuItem(
                                        value: e.key, child: Text(e.value))),
                              ],
                              onChanged: (v) => setState(() {
                                fazendaId = v;
                                _consultarSaldo();
                              }),
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Erro fazendas: $e'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: safraMapAsync.when(
                            data: (safraMap) => DropdownButtonFormField<String>(
                              value: safraId,
                              decoration:
                                  const InputDecoration(labelText: 'Safra'),
                              items: [
                                const DropdownMenuItem(
                                    value: null, child: Text('Todas')),
                                ...safraMap.entries.map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value))),
                              ],
                              onChanged: (v) => setState(() {
                                safraId = v;
                                _consultarSaldo();
                              }),
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Erro safras: $e'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      produtoMapaAsync.when(
                        data: (produtos) => DropdownButtonFormField<String>(
                          value: produtoId,
                          decoration:
                              const InputDecoration(labelText: 'Produto'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Todos')),
                            ...produtos.entries.map((e) => DropdownMenuItem(
                                value: e.key, child: Text(e.value))),
                          ],
                          onChanged: (v) => setState(() {
                            produtoId = v;
                            _consultarSaldo();
                          }),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Erro produtos: $e'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Saldo atual: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(saldoAtual.toStringAsFixed(2)),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              produtoId = null;
                              fazendaId = null;
                              safraId = null;
                              saldoAtual = 0;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text("Limpar Filtros"),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: estoquesAsync.when(
                    data: (estoques) => produtoMapaAsync.when(
                      data: (produtoMap) => fazendaMapAsync.when(
                        data: (fazendaMap) => safraMapAsync.when(
                          data: (safraMap) {
                            final dados = estoques
                                .where((e) =>
                                    (produtoId == null ||
                                        e.produtoId == produtoId) &&
                                    (fazendaId == null ||
                                        e.fazendaId == fazendaId) &&
                                    (safraId == null || e.safraId == safraId))
                                .map((e) {
                              return {
                                'produto':
                                    produtoMap[e.produtoId] ?? e.produtoId,
                                'quantidade': e.quantidade,
                                'tipo': e.tipo,
                                'safra':
                                    safraMap[e.safraId] ?? e.safraId ?? '-',
                                'fazenda': fazendaMap[e.fazendaId] ??
                                    e.fazendaId ??
                                    '-',
                                'data':
                                    e.data.toLocal().toString().split(' ')[0],
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
                                            'Tipo',
                                            'Safra',
                                            'Fazenda',
                                            'Data',
                                          ],
                                          data: dados,
                                          buildCells: (item) => [
                                            DataCell(Text(item['produto'])),
                                            DataCell(
                                                Text('${item['quantidade']}')),
                                            DataCell(Text(item['tipo'])),
                                            DataCell(Text(item['safra'])),
                                            DataCell(Text(item['fazenda'])),
                                            DataCell(Text(item['data'])),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) =>
                              Center(child: Text('Erro safras: $e')),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Center(child: Text('Erro fazendas: $e')),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Erro produtos: $e')),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erro estoque: $e')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        tooltip: 'Voltar ao topo',
        child: const Icon(Icons.arrow_upward, color: Colors.white),
        backgroundColor: const Color(0xFF59734A),
      ),
    );
  }
}
