import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/venda_provider.dart';
import 'package:fiap_farms_app/domain/entities/product.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/presentation/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphic/graphic.dart';

class SalesWidget extends ConsumerStatefulWidget {
  const SalesWidget({super.key});

  @override
  ConsumerState<SalesWidget> createState() => _SalesWidgetState();
}

class _SalesWidgetState extends ConsumerState<SalesWidget> {
  List<dynamic> vendas = [];
  Map<String, String> products = {};
  List<Map<String, Object?>> data = [];
  double totalValue = 0;

  @override
  void initState() {
    super.initState();

    loadVendas();
  }

  Future<void> loadProducts() async {
    final asyncProducts = ref.read(productRepositoryProvider);
    List<Product> data = await asyncProducts.getAllProducts();

    setState(() {
      products = {for (var product in data) product.id: product.nome};
    });
  }

  Future<void> loadVendas() async {
    await loadProducts();

    var dataMap = {};

    final asyncVendas = ref.read(vendaRepositoryProvider);

    vendas = await asyncVendas.getAll();

    setState(() {
      vendas.forEach((venda) {
        venda.itens.forEach((vendaItem) {
          // Soma, ao total vendas, a quantidade de itens vendidos.
          // vendasTotal += vendaItem.quantidade.toInt();

          dataMap[products[vendaItem.produtoId]] ??= {
            'name': products[vendaItem.produtoId],
            'value': 0.0
          };

          totalValue += vendaItem.valor;
          dataMap[products[vendaItem.produtoId]]['value'] += vendaItem.valor;
        });
      });

      dataMap.forEach((k, v) => data.add(v));
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titlesStyle = TextStyle(
      color: Color(0xFF97133E),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    if (data.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          padding: EdgeInsets.all(30),
          color: Color(0xFF97133E),
        ),
      );
    }

    return HomeCard(
      title: 'Vendas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vendas por Produto', style: titlesStyle),
          Container(
            height: 330,
            child: Chart(
              rebuild: false,
              data: data,
              variables: {
                'name': Variable(
                  accessor: (Map map) => map['name'] as String,
                ),
                'value': Variable(
                  accessor: (Map map) => map['value'] as num,
                ),
              },
              transforms: [
                Proportion(
                  variable: 'value',
                  as: 'percent',
                )
              ],
              marks: [
                IntervalMark(
                  position: Varset('percent') / Varset('name'),
                  label: LabelEncode(encoder: (tuple) {
                    double labelValue = (tuple['value'] / totalValue) * 100;

                    return Label(
                      '${labelValue.toStringAsPrecision(3)}%',
                      LabelStyle(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }),
                  color: ColorEncode(
                    variable: 'name',
                    values: Defaults.colors10,
                  ),
                  modifiers: [StackModifier()],
                  transition: Transition(
                    duration: const Duration(seconds: 2),
                  ),
                  entrance: {MarkEntrance.y},
                )
              ],
              coord: PolarCoord(
                transposed: true,
                dimCount: 1,
              ),
            ),
          ),
          Builder(
            builder: (context) {
              return Column(
                children: data.indexed.map((item) {
                  return Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: Defaults.colors10[item.$1],
                      ),
                      SizedBox(width: 6),
                      Text(
                        item.$2['name'] as String,
                        style: TextStyle(fontSize: 21),
                      )
                    ],
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
