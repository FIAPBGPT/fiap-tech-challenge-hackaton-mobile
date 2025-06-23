import 'package:fiap_farms_app/domain/entities/safra.dart';

abstract class SafraRepository {
  Future<void> createSafra(Safra safra);
  Future<void> updateSafra(Safra safra);
  Future<void> deleteSafra(String id);
  Stream<List<Safra>> watchAllSafras();
}
