import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/fazenda_repository.dart';
import '../../data/repositories/fazenda_repository_impl.dart';

final fazendaRepositoryProvider = Provider<FazendaRepository>((ref) {
  return FazendaRepositoryImpl(FirebaseFirestore.instance);
});

final fazendaListStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.read(fazendaRepositoryProvider);
  return repo.watchAllFazendas();
});

final fazendaMapProvider = Provider<AsyncValue<Map<String, String>>>((ref) {
  final fazendasAsync = ref.watch(fazendaListStreamProvider);
  
  return fazendasAsync.whenData((fazendas) {
    final mapa = <String, String>{};
    for (final f in fazendas) {
      mapa[f.id] = f.nome;  // Ajuste o campo 'nome' conforme sua entidade Fazenda
    }
    return mapa;
  });
});
