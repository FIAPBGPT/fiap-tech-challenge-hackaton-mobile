import 'package:cloud_firestore/cloud_firestore.dart';

class Estoque {
  final String id;
  final String produtoId;
  final String? safraId;
  final String? fazendaId;
  final double quantidade;
  final String tipo; // "entrada" ou "saida"
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

  Map<String, dynamic> toMap() => {
        'produtoId': produtoId,
        'safraId': safraId,
        'fazendaId': fazendaId,
        'quantidade': quantidade,
        'tipo': tipo,
        'observacao': observacao,
        'data': data,
      };

factory Estoque.fromMap(String id, Map<String, dynamic> m) {
  final produtoId = m['produtoId'] as String?;
  final tipo = m['tipo'] as String?;
  final quantidade = m['quantidade'];
  final data = m['data'];

  if (produtoId == null || tipo == null || quantidade == null || data == null || data is! Timestamp) {
    // Retorna null ou lança, depende do seu uso
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
    data: (data as Timestamp).toDate(),
  );
}


}
