import 'package:fiap_farms_app/data/repositories/meta_repository_impl.dart';
import 'package:fiap_farms_app/domain/entities/meta.dart';
import 'package:fiap_farms_app/domain/repositories/meta_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider do repositório
final metaRepositoryProvider = Provider<MetaRepository>(
  (ref) => MetaRepositoryImpl(FirebaseFirestore.instance),
);

// Acesso ao usuário atual
final authProvider = Provider<User?>(
  (ref) => FirebaseAuth.instance.currentUser,
);

// StreamProvider para a lista de metas do usuário
final metaListStreamProvider = StreamProvider<List<Meta>>((ref) {
  final repo = ref.watch(metaRepositoryProvider);
  final user = ref.watch(authProvider);
  if (user == null) return const Stream.empty();
  return repo.watchAllMetas().map(
    (metas) => metas
        .where((m) =>
            m.uid == user.uid &&
            m.produto.isNotEmpty &&
            m.safra.isNotEmpty &&
            m.fazenda.isNotEmpty &&
            m.tipo.isNotEmpty)
        .toList(),
  );
});
