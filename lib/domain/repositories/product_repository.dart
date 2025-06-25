import '../entities/product.dart';

abstract class ProductRepository {
  Future<void> createProduct(Product product);
  Future<List<Product>> getAllProducts();
  Stream<List<Product>> watchAllProducts();
   Future<void> updateProduct(Product product); 
  Future<void> deleteProduct(String id);       
}
