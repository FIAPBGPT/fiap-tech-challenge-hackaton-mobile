import 'package:fiap_farms_app/presentation/widgets/generic_table/generic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/product_provider.dart';
import '../widgets/product_form.dart';
import '../../domain/entities/product.dart';

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
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

  void _openForm(BuildContext context, {Product? product}) {
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
            color: Color(0xFF59734A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SafeArea(
            top: false,
            child: ProductForm(existing: product),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productListStreamProvider);
    final repo = ref.read(productRepositoryProvider);

    return Scaffold(      
        appBar: AppBar(
          title: const Text(
            'Produtos',
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
        onPressed: () => _openForm(context),
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xFF59734A),
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
          const Center(child: Text('Carregando produtos...')),
          productListAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return const Center(child: Text('Nenhum produto cadastrado.'));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: CustomPaginatedTable<Product>(
                            columns: const ['Nome', 'Categoria', 'Preço'],
                            data: products,
                            buildCells: (p) => [
                              DataCell(Text(p.nome)),
                              DataCell(Text(p.categoria ?? 'Sem categoria')),
                              DataCell(Text(
                                p.preco != null
                                    ? 'R\$ ${p.preco!.toStringAsFixed(2)}'
                                    : '--',
                              )),
                            ],
                            onEdit: (p) => _openForm(context, product: p),
                            onDelete: (p) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: Text('Deseja excluir o produto "${p.nome}"?'),
                              actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Excluir'),
                                    ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await repo.deleteProduct(p.id);
                          }
                        },
                      ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          ),
        ]) 
    );
  }
}
