import 'package:fiap_farms_app/domain/entities/estoque.dart';

abstract class EstoqueRepository {
  Stream<List<Estoque>> listarEstoque();
  Future<void> adicionarEstoque(Estoque e);
  Future<void> atualizarEstoque(String id, Map<String, dynamic> dados);
  Future<void> excluirEstoque(String id);
  Future<double> consultarSaldo({
    required String produtoId,
    String? safraId,
    String? fazendaId,
  });
}
