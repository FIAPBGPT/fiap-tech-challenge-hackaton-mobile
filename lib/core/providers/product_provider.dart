import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(FirebaseFirestore.instance);
});

final productListStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.read(productRepositoryProvider);
  return repo.watchAllProducts();
});

final produtoMapProvider = Provider<AsyncValue<Map<String, String>>>((ref) {
  final produtosAsync = ref.watch(productListStreamProvider);

  return produtosAsync.whenData((produtos) {
    return {
      for (final p in produtos) p.id: p.nome,
    };
  });
});
