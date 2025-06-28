import 'package:cloud_firestore/cloud_firestore.dart';

class Estoque {
  final String id;
  final String produtoId;
  final String? safraId;
  final String? fazendaId;
  final double quantidade;
  final String tipo; // 'entrada' ou 'saida'
  final String? observacao;
  final DateTime data;

  Estoque({
    required this.id,
    required this.produtoId,
    this.safraId,
    this.fazendaId,
    required this.quantidade,
    required this.tipo,
    this.observacao,
    required this.data,
  });

  /// Converte o objeto Estoque para um mapa compatível com Firestore
  Map<String, dynamic> toMap() => {
        'produtoId': produtoId,
        'safraId': safraId,
        'fazendaId': fazendaId,
        'quantidade': quantidade,
        'tipo': tipo,
        'observacao': observacao,
        'data': Timestamp.fromDate(data), // 🔥 Corrigido!
      };

  /// Construtor de fábrica que converte um mapa Firestore em um objeto Estoque
  factory Estoque.fromMap(String id, Map<String, dynamic> m) {
    final produtoId = m['produtoId'] as String?;
    final tipo = m['tipo'] as String?;
    final quantidade = m['quantidade'];
    final data = m['data'];

    if (produtoId == null ||
        tipo == null ||
        quantidade == null ||
        data == null ||
        data is! Timestamp) {
      throw Exception('Documento $id possui dados inválidos.');
    }

    return Estoque(
      id: id,
      produtoId: produtoId,
      safraId: m['safraId'] as String?,
      fazendaId: m['fazendaId'] as String?,
      quantidade: (quantidade as num).toDouble(),
      tipo: tipo,
      observacao: m['observacao'] as String?,
      data: data.toDate(),
    );
  }

  /// Permite criar uma cópia modificada do objeto Estoque
  Estoque copyWith({
    String? id,
    String? produtoId,
    String? safraId,
    String? fazendaId,
    double? quantidade,
    String? tipo,
    String? observacao,
    DateTime? data,
  }) {
    return Estoque(
      id: id ?? this.id,
      produtoId: produtoId ?? this.produtoId,
      safraId: safraId ?? this.safraId,
      fazendaId: fazendaId ?? this.fazendaId,
      quantidade: quantidade ?? this.quantidade,
      tipo: tipo ?? this.tipo,
      observacao: observacao ?? this.observacao,
      data: data ?? this.data,
    );
  }
}
