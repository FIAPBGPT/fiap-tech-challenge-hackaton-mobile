import '../entities/venda.dart';

abstract class VendaRepository {
  Future<void> addVenda(Venda venda);
  Future<void> updateVenda(Venda venda);
  Future<void> deleteVenda(Venda venda);
  Future<List<Venda>> getAll();
  Stream<List<Venda>> watchAllVendas();
}
