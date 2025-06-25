import 'package:fiap_farms_app/core/providers/estoque_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/producao.dart';
import '../../domain/repositories/producao_repository.dart';
import '../../data/repositories/producao_repository_impl.dart';

final producaoRepositoryProvider = Provider<ProducaoRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  final estoqueRepo = ref.read(estoqueRepositoryProvider);
  return ProducaoRepositoryImpl(firestore, estoqueRepo);
});

final producaoListStreamProvider = StreamProvider<List<Producao>>((ref) {
  final repo = ref.watch(producaoRepositoryProvider);
  return repo.watchAllProducoes();
});
