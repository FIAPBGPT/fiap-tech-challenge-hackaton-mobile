class Product {
  final String id;
  final String nome;
  final String? categoria;
  final double? preco;
  final bool? ativo;

  Product({
    required this.id,
    required this.nome,
    this.categoria,
    this.preco,
    this.ativo,
  });
}
