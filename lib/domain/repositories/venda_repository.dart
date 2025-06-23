import 'package:fiap_farms_app/domain/entities/venda.dart';

abstract class VendaRepository {
  Stream<List<Venda>> listarVendas();
  Future<String> adicionarVenda(Venda venda);
  Future<void> atualizarVenda(String id, Venda venda);
  Future<void> excluirVenda(String id);
}
