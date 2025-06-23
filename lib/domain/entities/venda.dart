// ----------------------
// domain/entities/venda.dart
// ----------------------
import 'package:cloud_firestore/cloud_firestore.dart';

class Venda {
  final String id;
  final String produtoId;
  final String safraId;
  final String fazendaId;
  final double quantidade;
  final double valor;
  final String uid;
  final DateTime data;

  Venda({
    required this.id,
    required this.produtoId,
    required this.safraId,
    required this.fazendaId,
    required this.quantidade,
    required this.valor,
    required this.uid,
    required this.data,
  });

  factory Venda.fromMap(String id, Map<String, dynamic> map) {
    return Venda(
      id: id,
      produtoId: map['produto'] ?? map['produtoId'] ?? '',
      safraId: map['safraId'] ?? '',
      fazendaId: map['fazenda'] ?? map['fazendaId'] ?? '',
      quantidade: (map['quantidade'] as num?)?.toDouble() ?? 0.0,
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      uid: map['uid'] ?? '',
      data: (map['data'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'produto': produtoId,
      'safraId': safraId,
      'fazenda': fazendaId,
      'quantidade': quantidade,
      'valor': valor,
      'uid': uid,
      'data': Timestamp.fromDate(data),
    };
  }

  Venda copyWith({
    String? id,
    String? produtoId,
    String? safraId,
    String? fazendaId,
    double? quantidade,
    double? valor,
    String? uid,
    DateTime? data,
  }) {
    return Venda(
      id: id ?? this.id,
      produtoId: produtoId ?? this.produtoId,
      safraId: safraId ?? this.safraId,
      fazendaId: fazendaId ?? this.fazendaId,
      quantidade: quantidade ?? this.quantidade,
      valor: valor ?? this.valor,
      uid: uid ?? this.uid,
      data: data ?? this.data,
    );
  }
}
