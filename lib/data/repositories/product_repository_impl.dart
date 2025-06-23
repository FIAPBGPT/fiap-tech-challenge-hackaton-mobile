import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore firestore;

  ProductRepositoryImpl(this.firestore);

  @override
  Future<void> createProduct(Product product) async {
await firestore.collection('produtos').doc(product.id).set({
  'nome': product.nome,
  'categoria': product.categoria,
  'preco': product.preco,
  'ativo': product.ativo ?? true,
});
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final snapshot = await firestore.collection('produtos').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        nome: data['nome'],
        categoria: data['categoria'],
        preco: (data['preco'] as num).toDouble(),
      );
    }).toList();
  }

  @override
Stream<List<Product>> watchAllProducts() {
  return firestore.collection('produtos').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
  final data = doc.data();
  return Product(
    id: doc.id,
    nome: data['nome'],
    categoria: data['categoria'],
    preco: (data['preco'] as num?)?.toDouble(),
    ativo: data['ativo'] ?? true,
  );
}).toList();
  });
}

@override
Future<void> updateProduct(Product product) async {
  await firestore.collection('produtos').doc(product.id).update({
    'nome': product.nome,
    'categoria': product.categoria,
    'preco': product.preco,
    'ativo': product.ativo ?? true,
  });
}

@override
Future<void> deleteProduct(String id) async {
  await firestore.collection('produtos').doc(id).delete();
}
}
