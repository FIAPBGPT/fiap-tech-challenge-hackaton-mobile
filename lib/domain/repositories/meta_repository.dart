import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/domain/entities/meta.dart';

class MetaRepository {
  final FirebaseFirestore firestore;
  MetaRepository({required this.firestore});

  CollectionReference get _metasRef => firestore.collection('metas');

  Stream<List<Meta>> watchAllMetas() {
    return _metasRef.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Meta.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addMeta(Meta meta) async {
    await _metasRef.add(meta.toFirestore());
  }

  Future<void> updateMeta(String id, Meta meta) async {
    await _metasRef.doc(id).update(meta.toFirestore());
  }

  Future<void> deleteMeta(String id) async {
    await _metasRef.doc(id).delete();
  }

  Future<List<Meta>> getAll() {
    throw UnimplementedError();
  }
}
