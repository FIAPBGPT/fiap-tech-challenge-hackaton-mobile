import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/domain/entities/estoque.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EstoqueForm extends ConsumerStatefulWidget {
  final Estoque? existing;
  final VoidCallback? onSuccess;

  const EstoqueForm({this.existing, this.onSuccess, super.key});

  @override
  ConsumerState<EstoqueForm> createState() => _EstoqueFormState();
}

class _EstoqueFormState extends ConsumerState<EstoqueForm> {
  final _qController = TextEditingController();
  final _obsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String produto = '';
  String? safra;
  String? fazenda;
  String tipo = 'entrada';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      produto = e.produtoId;
      safra = e.safraId;
      fazenda = e.fazendaId;
      tipo = e.tipo;
      _qController.text = e.quantidade.toString();
      _obsController.text = e.observacao ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtos = ref.watch(productListStreamProvider);
    final safras = ref.watch(safraListStreamProvider);
    final fazendas = ref.watch(fazendaListStreamProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          produtos.when(
            data: (produtosList) => DropdownButtonFormField<String>(
              value: produto.isNotEmpty ? produto : null,
              decoration: const InputDecoration(labelText: 'Produto'),
              items: produtosList
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
                  .toList(),
              onChanged: (value) => setState(() => produto = value ?? ''),
              validator: (value) => value == null || value.isEmpty ? 'Selecione um produto' : null,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => const Text('Erro ao carregar produtos'),
          ),
          safras.when(
            data: (safrasList) => DropdownButtonFormField<String>(
              value: safra,
              decoration: const InputDecoration(labelText: 'Safra'),
              items: safrasList
                  .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nome)))
                  .toList(),
              onChanged: (value) => setState(() => safra = value),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => const Text('Erro ao carregar safras'),
          ),
          fazendas.when(
            data: (fazendasList) => DropdownButtonFormField<String>(
              value: fazenda,
              decoration: const InputDecoration(labelText: 'Fazenda'),
              items: fazendasList
                  .map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome)))
                  .toList(),
              onChanged: (value) => setState(() => fazenda = value),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => const Text('Erro ao carregar fazendas'),
          ),
          TextFormField(
            controller: _qController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade'),
            validator: (v) => (v == null || double.tryParse(v) == null) ? 'Informe uma quantidade válida' : null,
          ),
          DropdownButtonFormField<String>(
            value: tipo,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
              DropdownMenuItem(value: 'saida', child: Text('Saída')),
            ],
            onChanged: (value) => setState(() => tipo = value ?? 'entrada'),
          ),
          TextFormField(
            controller: _obsController,
            decoration: const InputDecoration(labelText: 'Observação'),
            maxLines: null,
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
