import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/producao_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/domain/entities/producao.dart';
import 'package:fiap_farms_app/presentation/widgets/producao_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProducaoPage extends ConsumerStatefulWidget {
  const ProducaoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProducaoPage> createState() => _ProducaoPageState();
}

class _ProducaoPageState extends ConsumerState<ProducaoPage> {
  Producao? producaoEditando;

  void _abrirForm([Producao? p]) {
    setState(() => producaoEditando = p);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.all(16),
          child: ProducaoForm(producao: p), // <-- Envia a produção para edição
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
      appBar: AppBar(title: const Text('Produção')),
      body: producoesAsync.when(
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
                      return ListView.builder(
                        itemCount: producoes.length,
                        itemBuilder: (context, index) {
                          final p = producoes[index];
                          final fazendaNome =
                              fazendaMap[p.fazenda] ?? p.fazenda ?? 'N/A';
                          final produtoNome =
                              produtoMap[p.produto] ?? p.produto;
                          final safraNome =
                              safraMap[p.safra] ?? p.safra ?? 'N/A';
                          return ListTile(
                            title: Text(produtoNome ?? p.produto),
                            subtitle: Text(
                              'Qtd: ${p.quantidade} | Safra: ${safraNome ?? '-'} | Fazenda: ${fazendaNome ?? '-'}\n'
                              'Data: ${p.data.toLocal().toString().split(' ')[0]}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: 'Editar',
                                  onPressed: () => _abrirForm(p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Excluir',
                                  onPressed: () => _excluir(p),
                                ),
                              ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Produção',
      ),
    );
  }
}
