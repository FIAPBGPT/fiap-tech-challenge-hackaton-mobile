import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/repositories/safra_repository_impl.dart';
import '../../domain/repositories/safra_repository.dart';
import '../../domain/entities/safra.dart';

/// Provider do repositório de safra
final safraRepositoryProvider = Provider<SafraRepository>((ref) {
  return SafraRepositoryImpl(FirebaseFirestore.instance);
});

/// Provider do stream com a lista de safras em tempo real
final safraListStreamProvider = StreamProvider<List<Safra>>((ref) {
  final repo = ref.read(safraRepositoryProvider);
  return repo.watchAllSafras();
});

final safraMapProvider = Provider<AsyncValue<Map<String, String>>>((ref) {
  final safrasAsync = ref.watch(safraListStreamProvider);
  
  return safrasAsync.whenData((safras) {
    final mapa = <String, String>{};
    for (final s in safras) {
      mapa[s.id] = s.nome; // Ajuste o campo 'nome' conforme sua entidade Safra
    }
    return mapa;
  });
});
