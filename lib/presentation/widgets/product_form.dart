import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../core/providers/product_provider.dart';
import 'package:uuid/uuid.dart';

class ProductForm extends ConsumerStatefulWidget {
  final Product? existing;

  const ProductForm({super.key, this.existing});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? selectedCategory;
  bool isActive = true;

  final categorias = ["C1", "C2", "S1", "S2", "Genética", "Básica"];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.nome;
      _priceController.text = widget.existing!.preco?.toString() ?? '';
      selectedCategory = widget.existing!.categoria;
      isActive = widget.existing!.ativo ?? true;
    }
  }

  Future<void> _submit() async {
    final repo = ref.read(productRepositoryProvider);

    final product = Product(
      id: widget.existing?.id ?? const Uuid().v4(),
      nome: _nameController.text.trim(),
      categoria: selectedCategory,
      preco: _priceController.text.isNotEmpty
          ? double.tryParse(_priceController.text.trim())
          : null,
      ativo: isActive,
    );

    if (widget.existing != null) {
      await repo.updateProduct(product);
    } else {
      await repo.createProduct(product);
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.existing != null ? 'Editar Produto' : 'Novo Produto',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome do Produto'),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedCategory,
            hint: const Text("Selecione a categoria"),
            items: categorias.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: (value) => setState(() => selectedCategory = value),
            decoration: const InputDecoration(labelText: "Categoria"),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Preço'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Checkbox(
                value: isActive,
                onChanged: (val) => setState(() => isActive = val ?? true),
              ),
              const Text("Produto ativo"),
            ],
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.existing != null ? 'Atualizar Produto' : 'Cadastrar Produto'),
          ),
        ],
      ),
    );
  }
}
