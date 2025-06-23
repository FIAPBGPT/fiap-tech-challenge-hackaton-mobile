import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/producao.dart';
import '../../domain/repositories/producao_repository.dart';
import '../../data/repositories/producao_repository_impl.dart';

final producaoRepositoryProvider = Provider<ProducaoRepository>((ref) {
  return ProducaoRepositoryImpl(FirebaseFirestore.instance);
});

final producaoListStreamProvider = StreamProvider<List<Producao>>((ref) {
  final repo = ref.read(producaoRepositoryProvider);
  return repo.watchAllProducoes();
});
final producaoSaldoEstoqueProvider = FutureProvider.family<int, String>((ref, produtoId) async {
  final repo = ref.read(producaoRepositoryProvider);
  return repo.consultarSaldoEstoque(produtoId);
});
