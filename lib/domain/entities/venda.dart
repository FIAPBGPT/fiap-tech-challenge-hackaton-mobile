import 'package:cloud_firestore/cloud_firestore.dart';

class Venda {
  final String id;
  final List<VendaItem> itens;
  final DateTime data;

  Venda({
    required this.id,
    required this.itens,
    required this.data,
  });

  Map<String, dynamic> toMap([String? forcedId]) {
    return {
      'data': Timestamp.fromDate(data),
      'itens': itens.map((i) => i.toMap()).toList(),
    };
  }

  factory Venda.fromMap(Map<String, dynamic> map, String id) {
    return Venda(
      id: id,
      data: (map['data'] as Timestamp).toDate(),
      itens: (map['itens'] as List)
          .map((i) => VendaItem.fromMap(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Venda copyWith({
    String? id,
    List<VendaItem>? itens,
    DateTime? data,
  }) {
    return Venda(
      id: id ?? this.id,
      itens: itens ?? this.itens,
      data: data ?? this.data,
    );
  }
}

class VendaItem {
  final String produtoId;
  final String? safraId;
  final String? fazendaId;
  final double quantidade;
  final double valor;
  final String uid;

  VendaItem({
    required this.produtoId,
    required this.quantidade,
    required this.valor,
    required this.uid,
    this.safraId,
    this.fazendaId,
  }) {
    assert(produtoId.isNotEmpty, 'produtoId não pode estar vazio');
    assert(uid.isNotEmpty, 'uid é obrigatório');
    assert(quantidade > 0, 'quantidade deve ser maior que zero');
    assert(valor >= 0, 'valor não pode ser negativo');
  }

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'quantidade': quantidade,
      'valor': valor,
      'uid': uid,
      if (safraId != null) 'safraId': safraId,
      if (fazendaId != null) 'fazendaId': fazendaId,
    };
  }

  factory VendaItem.fromMap(Map<String, dynamic> map) {
    return VendaItem(
      produtoId: map['produtoId'] ?? '',
      quantidade: (map['quantidade'] as num).toDouble(),
      valor: (map['valor'] as num).toDouble(),
      uid: map['uid'] ?? '',
      safraId: map['safraId'],
      fazendaId: map['fazendaId'],
    );
  }

  VendaItem copyWith({
    String? produtoId,
    String? safraId,
    String? fazendaId,
    double? quantidade,
    double? valor,
    String? uid,
  }) {
    return VendaItem(
      produtoId: produtoId ?? this.produtoId,
      safraId: safraId ?? this.safraId,
      fazendaId: fazendaId ?? this.fazendaId,
      quantidade: quantidade ?? this.quantidade,
      valor: valor ?? this.valor,
      uid: uid ?? this.uid,
    );
  }
}
