import 'package:fiap_farms_app/domain/entities/estoque.dart';
import 'package:fiap_farms_app/domain/entities/fazenda.dart';
import 'package:fiap_farms_app/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/venda_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/fazenda_provider.dart';
import '../../domain/entities/venda.dart';
import '../widgets/venda_form.dart';
import '../../core/providers/estoque_provider.dart';

class VendaPage extends ConsumerStatefulWidget {
  const VendaPage({Key? key}) : super(key: key);

  @override
  ConsumerState<VendaPage> createState() => _VendaPageState();
}

class _VendaPageState extends ConsumerState<VendaPage> {
  Venda? vendaEditando;

  void _abrirForm([Venda? venda]) {
    setState(() {
      vendaEditando = venda;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
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
              existing: vendaEditando,
              onSuccess: () {
                Navigator.pop(context);
                setState(() => vendaEditando = null);
              },
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
        title: const Text('Excluir Venda'),
        content: const Text('Tem certeza que deseja excluir esta venda? O estoque será reabastecido.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final vendaRepo = ref.read(vendaRepositoryProvider);
      final estoqueRepo = ref.read(estoqueRepositoryProvider);

      await vendaRepo.excluirVenda(venda.id);

      await estoqueRepo.adicionarEstoque(
        Estoque(
          id: const Uuid().v4(),
          produtoId: venda.produtoId,
          safraId: venda.safraId.isEmpty ? null : venda.safraId,
          fazendaId: venda.fazendaId,
          quantidade: venda.quantidade,
          tipo: 'entrada',
          observacao: 'Reabastecimento por exclusão da venda ID: ${venda.id}',
          data: DateTime.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venda excluída com sucesso.')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir venda: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendasAsync = ref.watch(vendaListStreamProvider);
    final produtosAsync = ref.watch(productListStreamProvider);
    final fazendasAsync = ref.watch(fazendaListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendas'),
      ),
      body: vendasAsync.when(
        data: (vendas) {
          if (vendas.isEmpty) return const Center(child: Text('Nenhuma venda cadastrada'));

          // Evita duplicatas pelo ID, se necessário:
          final uniqueVendasMap = <String, Venda>{};
          for (final v in vendas) {
            uniqueVendasMap[v.id] = v;
          }
          final uniqueVendas = uniqueVendasMap.values.toList();

          return produtosAsync.when(
            data: (produtos) => fazendasAsync.when(
              data: (fazendas) {
                return ListView.builder(
                  itemCount: uniqueVendas.length,
                  itemBuilder: (_, i) {
                    final venda = uniqueVendas[i];

                    final produto = produtos.firstWhere(
                      (p) => p.id == venda.produtoId,
                      orElse: () => Product(id: venda.produtoId, nome: 'Produto Desconhecido'),
                    );

                    // Fazenda pode ser nome ou id — tentar achar pelo id, senão usa valor bruto
                    final fazendaRaw = venda.fazendaId;
                    final fazendaObj = fazendas.firstWhere(
                      (f) => f.id == fazendaRaw,
                      orElse: () => Fazenda(
                        id: '',
                        nome: fazendaRaw,
                        estado: '',
                        latitude: 0.0,
                        longitude: 0.0,
                      ),
                    );

                    final fazendaNome = fazendaObj.nome.isNotEmpty ? fazendaObj.nome : venda.fazendaId;

                    return ListTile(
                      title: Text(produto.nome),
                      subtitle: Text(
                        'Qtd: ${venda.quantidade}, R\$ ${venda.valor.toStringAsFixed(2)}, Fazenda: $fazendaNome',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _abrirForm(venda),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _excluirVenda(venda),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro ao carregar fazendas: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar produtos: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar vendas: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
