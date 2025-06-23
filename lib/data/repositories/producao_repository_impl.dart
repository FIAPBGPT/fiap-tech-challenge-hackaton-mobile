import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/producao.dart';
import '../../domain/repositories/producao_repository.dart';

class ProducaoRepositoryImpl implements ProducaoRepository {
  final FirebaseFirestore firestore;

  ProducaoRepositoryImpl(this.firestore);

  @override
  Future<void> updateProducao(Producao p) async {
    await firestore.collection('producoes').doc(p.id).update({
      'produto': p.produto,
      'quantidade': p.quantidade,
      'fazenda': p.fazenda,
      'safra': p.safra,
      'uid': p.uid,
    });
  }

  @override
  Future<void> deleteProducao(String id) async {
    await firestore.collection('producoes').doc(id).delete();
  }

@override
Stream<List<Producao>> watchAllProducoes() {
  return firestore.collection('producoes').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Producao.fromMap(doc.data(), doc.id);
    }).toList();
  });
}

  @override
  Future<int> consultarSaldoEstoque(String produtoId) async {
    final snapshot = await firestore.collection('estoque')
        .where('produto', isEqualTo: produtoId)
        .get();

    int total = 0;
    for (var doc in snapshot.docs) {
      final quantidade = (doc.data()['quantidade'] as num?)?.toInt() ?? 0;
      total += quantidade;
    }
    return total;
  }

  @override
  Future<void> registrarProducaoEstoque(Producao producao) async {
    await firestore.collection('estoque').add({
      'produto': producao.produto,
      'quantidade': producao.quantidade,
      'fazenda': producao.fazenda,
      'safra': producao.safra,
      'data': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<DocumentReference> addProducaoRetornandoRef(Producao p) async {
    final docRef = firestore.collection('producoes').doc();

    await docRef.set({
      'id': docRef.id,
      'produto': p.produto,
      'quantidade': p.quantidade,
      'fazenda': p.fazenda,
      'safra': p.safra,
      'uid': p.uid,
    });

    return docRef;
  }
}
