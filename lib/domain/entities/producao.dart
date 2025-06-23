class Producao {
  final String id;
  final String uid;
  final String produto;
  final int quantidade;
  final String fazenda;
  final String safra;

  Producao({
    required this.id,
    required this.uid,
    required this.produto,
    required this.quantidade,
    required this.fazenda,
    required this.safra,
  });


  factory Producao.fromMap(Map<String, dynamic> data, String documentId) {
    return Producao(
      id: documentId,
      uid: data['uid'] ?? '',
      produto: data['produto'] ?? '',
      quantidade: (data['quantidade'] as num?)?.toInt() ?? 0,
      fazenda: data['fazenda'] ?? '',
      safra: data['safra'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'produto': produto,
      'quantidade': quantidade,
      'fazenda': fazenda,
      'safra': safra,
    };
  }


  Producao copyWith({
    String? id,
    String? uid,
    String? produto,
    int? quantidade,
    String? fazenda,
    String? safra,
  }) {
    return Producao(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      produto: produto ?? this.produto,
      quantidade: quantidade ?? this.quantidade,
      fazenda: fazenda ?? this.fazenda,
      safra: safra ?? this.safra,
    );
  }
}
