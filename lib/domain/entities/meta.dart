import 'package:cloud_firestore/cloud_firestore.dart';

class Meta {
  final String id;
  final String produto;
  final double valor;
  final String safra;
  final String fazenda;
  final String tipo;
  final String uid;

  Meta({
    required this.id,
    required this.produto,
    required this.valor,
    required this.safra,
    required this.fazenda,
    required this.tipo,
    required this.uid,
  });

factory Meta.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};

  return Meta(
    id: doc.id,
    produto: data['produto'] as String? ?? '',
    valor: (data['valor'] as num?)?.toDouble() ?? 0.0,
    safra: data['safra'] as String? ?? '',
    fazenda: data['fazenda'] as String? ?? '',
    tipo: data['tipo'] as String? ?? '',
    uid: data['uid'] as String? ?? '',
  );
}

  Map<String, dynamic> toFirestore() {
    return {
      'produto': produto,
      'valor': valor,
      'safra': safra,
      'fazenda': fazenda,
      'tipo': tipo,
      'uid': uid,
    };
  }

  Meta copyWith({
    String? id,
    String? produto,
    double? valor,
    String? safra,
    String? fazenda,
    String? tipo,
    String? uid,
  }) {
    return Meta(
      id: id ?? this.id,
      produto: produto ?? this.produto,
      valor: valor ?? this.valor,
      safra: safra ?? this.safra,
      fazenda: fazenda ?? this.fazenda,
      tipo: tipo ?? this.tipo,
      uid: uid ?? this.uid,
    );
  }
}
