import 'package:cloud_firestore/cloud_firestore.dart';

class Movimentacao {
  final String? id;
  final List<MovimentacaoItem> itens;
  final DateTime? data;
  final String? origem;
  final String? referenciaId;

  Movimentacao({
    this.id,
    required this.itens,
    this.data,
    this.origem,
    this.referenciaId,
  });

  factory Movimentacao.fromMap(Map<String, dynamic> map) {
    return Movimentacao(
      id: map['id'],
      itens: (map['itens'] as List<dynamic>)
          .map((e) => MovimentacaoItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      data: map['data'] != null
          ? (map['data'] as Timestamp).toDate()
          : null,
      origem: map['origem'],
      referenciaId: map['referenciaId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itens': itens.map((e) => e.toMap()).toList(),
      'data': data,
      'origem': origem,
      'referenciaId': referenciaId,
    };
  }
}

class MovimentacaoItem {
  final String produtoId;
  final double quantidade;
  final String? safraId;
  final String? fazendaId;

  MovimentacaoItem({
    required this.produtoId,
    required this.quantidade,
    this.safraId,
    this.fazendaId,
  });

  factory MovimentacaoItem.fromMap(Map<String, dynamic> map) {
    return MovimentacaoItem(
      produtoId: map['produtoId'],
      quantidade: (map['quantidade'] as num).toDouble(),
      safraId: map['safraId'],
      fazendaId: map['fazendaId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'quantidade': quantidade,
      'safraId': safraId,
      'fazendaId': fazendaId,
    };
  }
}
