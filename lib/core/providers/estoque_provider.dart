import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/data/repositories/estoque_repository_impl.dart';
import 'package:fiap_farms_app/domain/entities/estoque.dart';
import 'package:fiap_farms_app/domain/repositories/estoque_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final estoqueRepositoryProvider = Provider<EstoqueRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return EstoqueRepositoryImpl(firestore: firestore);
});

final estoqueListStreamProvider = StreamProvider.autoDispose<List<Estoque>>((ref) {
  final repo = ref.watch(estoqueRepositoryProvider);
  return repo.listarEstoque();
});
