import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/data/repositories/venda_repository_impl.dart';
import 'package:fiap_farms_app/domain/repositories/venda_repository.dart';

final vendaRepositoryProvider = Provider<VendaRepository>((ref) {
  return VendaRepositoryImpl(FirebaseFirestore.instance);
});

final vendaListStreamProvider = StreamProvider.autoDispose<List<Venda>>((ref) {
  final repo = ref.watch(vendaRepositoryProvider);
  return repo.listarVendas();
});
