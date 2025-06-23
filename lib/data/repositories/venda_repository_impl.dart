import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/domain/repositories/venda_repository.dart';

class VendaRepositoryImpl implements VendaRepository {
  final FirebaseFirestore firestore;
  final CollectionReference _col;

  VendaRepositoryImpl(this.firestore) : _col = firestore.collection('vendas');

  @override
  Stream<List<Venda>> listarVendas() {
    return _col.snapshots().map((snapshot) {
      final unique = <String, Venda>{};
      for (final doc in snapshot.docs) {
        try {
          final venda = Venda.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          unique[venda.id] = venda;
        } catch (e) {
          print('Erro ao converter venda: $e');
        }
      }
      return unique.values.toList();
    });
  }

  @override
  Future<String> adicionarVenda(Venda venda) async {
    await _col.doc(venda.id).set(venda.toMap());
    return venda.id;
  }

  @override
  Future<void> atualizarVenda(String id, Venda venda) async {
    await _col.doc(id).update(venda.toMap());
  }

  @override
  Future<void> excluirVenda(String id) async {
    await _col.doc(id).delete();
  }
}
