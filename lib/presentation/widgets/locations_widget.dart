import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/producao_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/domain/entities/fazenda.dart';
import 'package:fiap_farms_app/domain/entities/producao.dart';
import 'package:fiap_farms_app/domain/entities/product.dart';
import 'package:fiap_farms_app/presentation/widgets/home_card.dart';
import 'package:fiap_farms_app/presentation/widgets/locations_widget/product_quantity.dart';
import 'package:fiap_farms_app/presentation/widgets/locations_widget/state_farms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

class LocationsWidget extends ConsumerStatefulWidget {
  const LocationsWidget({super.key});

  @override
  ConsumerState<LocationsWidget> createState() => _LocationsWidgetState();
}

class _LocationsWidgetState extends ConsumerState<LocationsWidget> {
  int fazendasQuantity = 0;
  List<Product> products = [];
  List<Fazenda> fazendas = [];
  List<Producao> producoes = [];
  Map<String, List<String>> fazendasByProduct = {};

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    await loadProducts();
    await loadFazendas();
    await buildFazendasByProduct();
  }

  Future<void> loadProducts() async {
    final asyncProducts = ref.read(productRepositoryProvider);
    List<Product> data = await asyncProducts.getAllProducts();

    setState(() {
      products = data;
    });
  }

  Future<void> loadFazendas() async {
    final asyncFarms = ref.read(fazendaRepositoryProvider);
    List<Fazenda> data = await asyncFarms.getAll();

    setState(() {
      fazendas = data;
      fazendasQuantity = fazendas.length;
    });
  }

  Future<void> buildFazendasByProduct() async {
    final asyncProducoes = ref.read(producaoRepositoryProvider);
    List<Producao> data = await asyncProducoes.getAll();

    setState(() {
      data.forEach((producao) {
        Fazenda fazenda;
        Product product;

        product = products.firstWhere((p) => p.id == producao.produto);
        fazenda = fazendas.firstWhere((f) => f.id == producao.fazenda);

        if (product != null && fazenda != null) {
          fazendasByProduct[product.nome] ??= [];

          if (!fazendasByProduct[product.nome]!.contains(fazenda.id)) {
            fazendasByProduct[product.nome]!.add(fazenda.id);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final estadosBrasileiros = {
      'AC': 'Acre',
      'AL': 'Alagoas',
      'AP': 'Amapá',
      'AM': 'Amazonas',
      'BA': 'Bahia',
      'CE': 'Ceará',
      'DF': 'Distrito Federal',
      'ES': 'Espírito Santo',
      'GO': 'Goiás',
      'MA': 'Maranhão',
      'MG': 'Minas Gerais',
      'MS': 'Mato Grosso do Sul',
      'MT': 'Mato Grosso',
      'PA': 'Pará',
      'PB': 'Paraíba',
      'PE': 'Pernambuco',
      'PI': 'Piauí',
      'PR': 'Paraná',
      'RJ': 'Rio de Janeiro',
      'RN': 'Rio Grande do Norte',
      'RO': 'Rondônia',
      'RR': 'Roraima',
      'RS': 'Rio Grande do Sul',
      'SC': 'Santa Catarina',
      'SE': 'Sergipe',
      'SP': 'São Paulo',
      'TO': 'Tocantins',
    };

    if (fazendasByProduct.isEmpty)
      return Center(
        child: CircularProgressIndicator(
          padding: EdgeInsets.all(30),
          color: Color(0xFF97133E),
        ),
      );

    return HomeCard(
      title: 'Localidades',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$fazendasQuantity Fazendas',
            style: TextStyle(
              color: Color(0xFF97133E),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 184,
                      height: 270,
                      child: Builder(builder: (context) {
                        Map groupedFazendas =
                            groupBy(fazendas, (f) => f.estado);

                        groupedFazendas = Map.fromEntries(
                            groupedFazendas.entries.toList()
                              ..sort((a, b) =>
                                  b.value.length.compareTo(a.value.length)));

                        return GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          childAspectRatio: 0.69,
                          children: groupedFazendas.keys
                              .toList()
                              .sublist(0, fazendas.isNotEmpty ? 4 : 0)
                              .map((key) {
                            int quantity = groupedFazendas[key].length;

                            double percentage =
                                (quantity / fazendas.length) * 100;

                            return StateFarms(
                              state: estadosBrasileiros[key]!,
                              farmsNumber: quantity,
                              percentage: percentage,
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'Quantidade de\nfazendas por\nproduto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFBB9F42),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 138,
                    height: 180,
                    child: ListView.builder(
                      itemCount: fazendasByProduct.keys.length,
                      itemBuilder: (context, index) {
                        String key = fazendasByProduct.keys.toList()[index];

                        return Column(children: [
                          SizedBox(
                            height: 9,
                          ),
                          ProductQuantity(
                            productName: key,
                            quantity: fazendasByProduct[key]!.length,
                          )
                        ]);
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
