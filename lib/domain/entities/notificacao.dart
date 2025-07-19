import 'package:fiap_farms_app/domain/entities/fazenda.dart';
import 'package:fiap_farms_app/domain/entities/meta.dart';
import 'package:fiap_farms_app/domain/entities/product.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';

class Notificacao {
  final String fazenda;
  final double valorVenda;
  final String produto;

  Notificacao(
      {required this.fazenda, required this.produto, required this.valorVenda});

  @override
  String toString() =>
      'Notificacao(fazenda: $fazenda, produto: $produto, valorVenda: $valorVenda)';
}

List<Notificacao> gerarNotificacoes({
  required List<Venda> vendas,
  required List<Meta> metas,
  required List<Fazenda> fazendas,
  required List<Product> produtos,
}) {
  final fazendaNomeMap = {
    for (final f in fazendas) f.id: f.nome,
  };

  final produtoNomeMap = {
    for (final p in produtos) p.id: p.nome,
  };

  final totalVendas = <String, double>{};
  for (final venda in vendas) {
    for (final item in venda.itens) {
      final fazendaId = item.fazendaId ?? 'sem_fazenda';
      final produtoId = item.produtoId;
      final key = '$fazendaId|$produtoId';
      final totalItem = item.valor * item.quantidade;
      totalVendas.update(key, (v) => v + totalItem, ifAbsent: () => totalItem);
    }
  }

  final totalMeta = <String, double>{};
  for (final meta in metas) {
    final key = '${meta.fazenda}|${meta.produto}';
    totalMeta.update(key, (v) => v + meta.valor, ifAbsent: () => meta.valor);
  }

  final notificacoes = <Notificacao>[];
  totalVendas.forEach((key, valorVenda) {
    final valorMeta = totalMeta[key] ?? 0;
    if (valorVenda >= valorMeta && valorMeta > 0) {
      final parts = key.split('|');
      final fazendaId = parts[0];
      final produtoId = parts[1];

      final nomeFazenda = fazendaNomeMap[fazendaId] ?? 'Fazenda desconhecida';
      final nomeProduto = produtoNomeMap[produtoId] ?? 'Produto desconhecido';

      notificacoes.add(Notificacao(
        fazenda: nomeFazenda,
        produto: nomeProduto,
        valorVenda: valorVenda,
      ));
    }
  });

  return notificacoes;
}
