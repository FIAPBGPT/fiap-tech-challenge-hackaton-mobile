
import 'package:flutter/material.dart';
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
  Estoque? estoqueEditando;
  String? produtoId;
  String? fazendaId;
  String? safraId;
  double saldoAtual = 0;

  Future<void> _consultarSaldo() async {
    final repo = ref.read(estoqueRepositoryProvider);
    final saldo = await repo.consultarSaldo(
      produtoId: produtoId ?? '',
      safraId: safraId,
      fazendaId: fazendaId,
    );
    setState(() => saldoAtual = saldo);
  }

  @override
  Widget build(BuildContext context) {
    final estoquesAsync = ref.watch(estoqueListStreamProvider);
    final produtoMapaAsync = ref.watch(produtoMapProvider);
    final fazendaMapAsync = ref.watch(fazendaMapProvider);
    final safraMapAsync = ref.watch(safraMapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estoque')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: fazendaMapAsync.when(
                    data: (fazendaMap) {
                      return DropdownButtonFormField<String>(
                        value: fazendaId,
                        decoration: const InputDecoration(labelText: 'Fazenda'),
                        items: [
                          const DropdownMenuItem<String>(
                              value: null, child: Text('Todas')),
                          ...fazendaMap.entries
                              .map(
                                (e) => DropdownMenuItem<String>(
                                    value: e.key, child: Text(e.value)),
                              )
                              .toList(),
                        ],
                        onChanged: (v) => setState(() {
                          fazendaId = v;
                          _consultarSaldo();
                        }),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Erro fazendas: $e'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: safraMapAsync.when(
                    data: (safraMap) {
                      return DropdownButtonFormField<String>(
                        value: safraId,
                        decoration: const InputDecoration(labelText: 'Safra'),
                        items: [
                          const DropdownMenuItem<String>(
                              value: null, child: Text('Todas')),
                          ...safraMap.entries
                              .map(
                                (e) => DropdownMenuItem<String>(
                                    value: e.key, child: Text(e.value)),
                              )
                              .toList(),
                        ],
                        onChanged: (v) => setState(() {
                          safraId = v;
                          _consultarSaldo();
                        }),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Erro safras: $e'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              produtoMapaAsync.when(
                data: (produtos) => DropdownButtonFormField<String>(
                  value: produtoId,
                  decoration: const InputDecoration(labelText: 'Produto'),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Todos')),
                    ...produtos.entries.map(
                      (e) => DropdownMenuItem<String>(
                          value: e.key, child: Text(e.value)),
                    ),
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
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: estoquesAsync.when(
              data: (estoques) => produtoMapaAsync.when(
                data: (produtoMap) => fazendaMapAsync.when(
                  data: (fazendaMap) => safraMapAsync.when(
                    data: (safraMap) => ListView.builder(
                      itemCount: estoques.length,
                      itemBuilder: (context, index) {
                        final e = estoques[index];
                        if (produtoId != null && produtoId != e.produtoId)
                          return const SizedBox.shrink();
                        if (fazendaId != null && fazendaId != e.fazendaId)
                          return const SizedBox.shrink();
                        if (safraId != null && safraId != e.safraId)
                          return const SizedBox.shrink();

                        final nomeProduto =
                            produtoMap[e.produtoId] ?? e.produtoId;
                        final nomeFazenda =
                            fazendaMap[e.fazendaId] ?? e.fazendaId ?? '-';
                        final nomeSafra =
                            safraMap[e.safraId] ?? e.safraId ?? '-';

                        return ListTile(
                          title: Text(nomeProduto),
                          subtitle: Text(
                            'Qtd: ${e.quantidade} | Tipo: ${e.tipo}\n'
                            'Safra: $nomeSafra | Fazenda: $nomeFazenda\n'
                            'Data: ${e.data.toLocal().toString().split(' ')[0]}',
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Erro ao carregar safras: $e')),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Erro ao carregar fazendas: $e')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro produtos: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro estoque: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
