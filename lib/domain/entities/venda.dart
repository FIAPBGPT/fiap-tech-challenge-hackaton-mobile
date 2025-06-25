import 'package:cloud_firestore/cloud_firestore.dart';

class VendaItem {
  final String produtoId;
  final String? safraId;
  final String? fazendaId;
  final double quantidade;

  VendaItem({
    required this.produtoId,
    this.safraId,
    this.fazendaId,
    required this.quantidade,
  });

  Map<String, dynamic> toMap() => {
        'produtoId': produtoId,
        'safraId': safraId,
        'fazendaId': fazendaId,
        'quantidade': quantidade,
      };

  factory VendaItem.fromMap(Map<String, dynamic> m) {
    return VendaItem(
      produtoId: m['produtoId'] as String,
      safraId: m['safraId'] as String?,
      fazendaId: m['fazendaId'] as String?,
      quantidade: (m['quantidade'] as num).toDouble(),
    );
  }

  VendaItem copyWith({
    String? produtoId,
    String? safraId,
    String? fazendaId,
    double? quantidade,
  }) {
    return VendaItem(
      produtoId: produtoId ?? this.produtoId,
      safraId: safraId ?? this.safraId,
      fazendaId: fazendaId ?? this.fazendaId,
      quantidade: quantidade ?? this.quantidade,
    );
  }
}

class Venda {
  final String id;
  final List<VendaItem> itens;
  final DateTime data;
  final String? observacao;

  Venda({
    required this.id,
    required this.itens,
    required this.data,
    this.observacao,
  });

  Map<String, dynamic> toMap([String? id]) => {
        'itens': itens.map((e) => e.toMap()).toList(),
        'data': data,
        'observacao': observacao,
      };

  factory Venda.fromMap(Map<String, dynamic> m, String id) {
    final data = m['data'];
    final itensRaw = m['itens'] as List<dynamic>;
    return Venda(
      id: id,
      itens: itensRaw.map((e) => VendaItem.fromMap(e)).toList(),
      data: (data is Timestamp) ? data.toDate() : (data as DateTime),
      observacao: m['observacao'] as String?,
    );
  }

  Venda copyWith({
    String? id,
    List<VendaItem>? itens,
    DateTime? data,
    String? observacao,
  }) {
    return Venda(
      id: id ?? this.id,
      itens: itens ?? this.itens,
      data: data ?? this.data,
      observacao: observacao ?? this.observacao,
    );
  }
}
