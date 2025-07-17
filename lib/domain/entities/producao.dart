import 'package:cloud_firestore/cloud_firestore.dart';

class Producao {
  final String id;
  final String produto;
  final String? safra;
  final String? fazenda;
  final double quantidade;
  final DateTime data;
  final String? observacao;
  final String? uid;

  Producao({
    required this.id,
    required this.produto,
    this.safra,
    this.fazenda,
    required this.quantidade,
    required this.data,
    this.observacao,
    required this.uid,
  });

  Map<String, dynamic> toMap([String? id]) => {
        'produto': produto,
        'safra': safra,
        'fazenda': fazenda,
        'quantidade': quantidade,
        'data': data,
        'observacao': observacao,
        'uid': uid,
      };

  factory Producao.fromMap(Map<String, dynamic> m, String id) {
    final dataRaw = m['data'];
    DateTime data;

    if (dataRaw == null) {
      throw Exception('Campo data está nulo no documento $id');
    } else if (dataRaw is Timestamp) {
      data = dataRaw.toDate();
    } else if (dataRaw is DateTime) {
      data = dataRaw;
    } else if (dataRaw is String) {
      data = DateTime.parse(dataRaw);
    } else {
      throw Exception('Campo data inválido no documento $id');
    }

    return Producao(
      id: id,
      produto: m['produto'] as String,
      safra: m['safra'] as String?,
      fazenda: m['fazenda'] as String?,
      quantidade: (m['quantidade'] as num).toDouble(),
      data: data,
      observacao: m['observacao'] as String?,
      uid: m['uid'] as String? ?? '',
    );
  }

  Producao copyWith({
    String? id,
    String? produto,
    String? safra,
    String? fazenda,
    double? quantidade,
    DateTime? data,
    String? observacao,
    String? uid,
  }) {
    return Producao(
      id: id ?? this.id,
      produto: produto ?? this.produto,
      safra: safra ?? this.safra,
      fazenda: fazenda ?? this.fazenda,
      quantidade: quantidade ?? this.quantidade,
      data: data ?? this.data,
      observacao: observacao ?? this.observacao,
      uid: uid ?? this.uid,
    );
  }
}
