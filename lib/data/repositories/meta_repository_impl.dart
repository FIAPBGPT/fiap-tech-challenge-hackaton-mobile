import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/domain/entities/meta.dart';
import 'package:fiap_farms_app/domain/repositories/meta_repository.dart';

class MetaRepositoryImpl implements MetaRepository {
  final FirebaseFirestore firestore;

  MetaRepositoryImpl(this.firestore);

  CollectionReference get _metasRef => firestore.collection('metas');

  Meta _fromDoc(DocumentSnapshot doc) => Meta.fromFirestore(doc);

  Map<String, dynamic> _toDoc(Meta meta) => meta.toFirestore();

  @override
  Future<void> addMeta(Meta meta) async {
    await _metasRef.add(_toDoc(meta));
  }

  @override
  Future<void> updateMeta(String id, Meta meta) async {
    await _metasRef.doc(id).update(_toDoc(meta));
  }

  @override
  Future<void> deleteMeta(String id) async {
    await _metasRef.doc(id).delete();
  }

  @override
  Stream<List<Meta>> watchAllMetas() {
    return _metasRef.snapshots().map(
          (snapshot) => snapshot.docs.map(_fromDoc).toList(),
        );
  }

  Future<List<Meta>> getAll() async {
    final snapshot = await firestore.collection('metas').get();

    return snapshot.docs.map(_fromDoc).toList();
  }
}
