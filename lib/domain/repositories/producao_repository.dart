import '../entities/producao.dart';

abstract class ProducaoRepository {
  Future<void> addProducao(Producao p);
  Future<void> updateProducao(Producao antiga, Producao atualizada);
  Future<void> deleteProducao(Producao p);
  Stream<List<Producao>> watchAllProducoes();
}
