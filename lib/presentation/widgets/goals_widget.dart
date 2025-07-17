import 'package:fiap_farms_app/core/providers/meta_provider.dart';
import 'package:fiap_farms_app/core/providers/producao_provider.dart';
import 'package:fiap_farms_app/core/providers/venda_provider.dart';
import 'package:fiap_farms_app/domain/entities/meta.dart';
import 'package:fiap_farms_app/domain/entities/producao.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/presentation/widgets/goal_bar.dart';
import 'package:fiap_farms_app/presentation/widgets/home_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalsWidget extends ConsumerStatefulWidget {
  const GoalsWidget({super.key});

  @override
  ConsumerState<GoalsWidget> createState() => _GoalsWidgetState();
}

class _GoalsWidgetState extends ConsumerState<GoalsWidget> {
  List<Producao> producoes = [];
  List<Venda> vendas = [];
  int vendaMeta = 0;
  int producaoMeta = 0;
  int producaoTotal = 0;
  int vendasTotal = 0;

  void initState() {
    super.initState();

    loadMetas();
    loadProducoes();
    loadVendas();
  }

  Future<void> loadProducoes() async {
    final asyncProducoes = ref.read(producaoRepositoryProvider);

    producoes = await asyncProducoes.getAll();

    setState(() {
      // Soma, à produção total, a quantidade produzida.
      producoes.forEach((p) => producaoTotal += p.quantidade.toInt());
    });
  }

  Future<void> loadMetas() async {
    final asyncMetas = ref.read(metaRepositoryProvider);

    List<Meta> metas = await asyncMetas.getAll();

    setState(() {
      metas.forEach((meta) {
        if (meta.tipo == 'vendas') {
          // Soma, à meta de vendas, a quantidade meta.
          vendaMeta += meta.valor.toInt();
        } else if (meta.tipo == 'producao') {
          // Soma, à meta de producao, a quantidade meta.
          producaoMeta += meta.valor.toInt();
        }
      });
    });
  }

  Future<void> loadVendas() async {
    final asyncVendas = ref.read(vendaRepositoryProvider);

    vendas = await asyncVendas.getAll();

    setState(() {
      vendas.forEach((venda) {
        venda.itens.forEach((vendaItem) {
          // Soma, ao total vendas, a quantidade de itens vendidos.
          vendasTotal += vendaItem.quantidade.toInt();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titlesStyle = TextStyle(
        color: Color(0xFF97133E), fontWeight: FontWeight.bold, fontSize: 18);

    if (producaoMeta == 0 || vendaMeta == 0)
      return Center(
        child: CircularProgressIndicator(
          padding: EdgeInsets.all(30),
          color: Color(0xFF97133E),
        ),
      );

    return HomeCard(
      title: 'Metas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vendas', style: titlesStyle),
          GoalBar(
            goalValue: vendaMeta.toDouble(),
            actualValue: vendasTotal.toDouble(),
          ),
          const SizedBox(height: 15),
          Text('Produção', style: titlesStyle),
          GoalBar(
            goalValue: producaoMeta.toDouble(),
            actualValue: producaoTotal.toDouble(),
          ),
        ],
      ),
    );
  }
}
