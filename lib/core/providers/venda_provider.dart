import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/core/providers/estoque_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/data/repositories/venda_repository_impl.dart';
import 'package:fiap_farms_app/domain/repositories/venda_repository.dart';

final vendaRepositoryProvider = Provider<VendaRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  final estoqueRepo = ref.read(estoqueRepositoryProvider);
  return VendaRepositoryImpl(firestore, estoqueRepo);
});

final vendaListStreamProvider = StreamProvider.autoDispose<List<Venda>>((ref) {
  final repo = ref.watch(vendaRepositoryProvider);
  return repo.watchAllVendas();
});
