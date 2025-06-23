import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/safra.dart';
import '../../domain/repositories/safra_repository.dart';

class SafraRepositoryImpl implements SafraRepository {
  final FirebaseFirestore firestore;

  SafraRepositoryImpl(this.firestore);

  @override
  Future<void> createSafra(Safra safra) async {
    await firestore.collection('safras').doc(safra.id).set({
      'nome': safra.nome,
      'valor': safra.valor, // string
    });
  }

  @override
  Future<void> updateSafra(Safra safra) async {
    await firestore.collection('safras').doc(safra.id).update({
      'nome': safra.nome,
      'valor': safra.valor, // string
    });
  }

  @override
  Future<void> deleteSafra(String id) async {
    await firestore.collection('safras').doc(id).delete();
  }

  @override
  Stream<List<Safra>> watchAllSafras() {
    return firestore.collection('safras').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Safra(
          id: doc.id,
          nome: data['nome'],
          valor: data['valor'] ?? '', // garante string mesmo que esteja faltando
        );
      }).toList();
    });
  }
}
