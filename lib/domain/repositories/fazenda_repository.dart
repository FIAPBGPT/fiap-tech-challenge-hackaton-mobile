import 'package:fiap_farms_app/domain/entities/fazenda.dart';

abstract class FazendaRepository {
  Future<void> createFazenda(Fazenda fazenda);
  Future<void> updateFazenda(Fazenda fazenda);
  Future<void> deleteFazenda(String id);
  Stream<List<Fazenda>> watchAllFazendas();
}
