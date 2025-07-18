import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/fazenda.dart';
import '../../domain/repositories/fazenda_repository.dart';

class FazendaRepositoryImpl implements FazendaRepository {
  final FirebaseFirestore firestore;

  FazendaRepositoryImpl(this.firestore);

  @override
  Future<void> createFazenda(Fazenda fazenda) async {
    await firestore.collection('fazendas').doc(fazenda.id).set({
      'nome': fazenda.nome,
      'estado': fazenda.estado,
      'latitude': fazenda.latitude,
      'longitude': fazenda.longitude,
    });
  }

  @override
  Future<void> updateFazenda(Fazenda fazenda) async {
    await firestore.collection('fazendas').doc(fazenda.id).update({
      'nome': fazenda.nome,
      'estado': fazenda.estado,
      'latitude': fazenda.latitude,
      'longitude': fazenda.longitude,
    });
  }

  @override
  Future<void> deleteFazenda(String id) async {
    await firestore.collection('fazendas').doc(id).delete();
  }

  @override
  Future<List<Fazenda>> getAll() async {
    final snapshot = await firestore.collection('fazendas').get();

    return snapshot.docs.map(_buildFazenda).toList();
  }

  @override
  Stream<List<Fazenda>> watchAllFazendas() {
    return firestore.collection('fazendas').snapshots().map((snapshot) {
      return snapshot.docs.map(_buildFazenda).toList();
    });
  }

  Fazenda _buildFazenda(dynamic doc) {
    final data = doc.data();

    return Fazenda(
      id: doc.id,
      nome: data['nome'],
      estado: data['estado'],
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
