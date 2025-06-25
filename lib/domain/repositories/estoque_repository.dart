import '../entities/estoque.dart';
import '../entities/producao.dart';
import '../entities/venda.dart';

abstract class EstoqueRepository {
  Future<Estoque> adicionarEstoque(Estoque e);
  Future<void> atualizarEstoque(String id, Map<String, dynamic> dados);
  Future<void> excluirEstoque(String id);
  Future<double> consultarSaldo({
    required String produtoId,
    String? safraId,
    String? fazendaId,
  });
  Future<Estoque> registrarEntradaProducao(Producao p);
  Future<void> removerEntradaProducao(Producao p);
  Future<List<Estoque>> registrarVendaEstoque(Venda venda);
  Future<List<Estoque>> reabastecerEstoqueVenda(Venda venda);
  Future<Estoque> registrarMovimentacao(Estoque e);
  Stream<List<Estoque>> listarEstoque();
}
