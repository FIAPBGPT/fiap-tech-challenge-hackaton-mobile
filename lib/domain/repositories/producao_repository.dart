import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/producao.dart';

abstract class ProducaoRepository {
  Future<void> updateProducao(Producao producao);
  Future<void> deleteProducao(String id);
  Stream<List<Producao>> watchAllProducoes();

  Future<int> consultarSaldoEstoque(String produtoId);
  Future<void> registrarProducaoEstoque(Producao producao);
  Future<DocumentReference> addProducaoRetornandoRef(Producao producao);
}
