import 'package:fiap_farms_app/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/producao.dart';
import '../../core/providers/producao_provider.dart';
import '../../core/providers/fazenda_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/safra_provider.dart';

class ProducaoForm extends ConsumerStatefulWidget {
  final Producao? existing;

  const ProducaoForm({this.existing, super.key});

  @override
  ConsumerState<ProducaoForm> createState() => _ProducaoFormState();
}

class _ProducaoFormState extends ConsumerState<ProducaoForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedProduto;
  String? selectedFazenda;
  String? selectedSafra;
  int? quantidade;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      selectedProduto = widget.existing!.produto;
      selectedFazenda = widget.existing!.fazenda;
      selectedSafra = widget.existing!.safra;
      quantidade = widget.existing!.quantidade;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(producaoRepositoryProvider);
    final produtosAsync = ref.watch(productListStreamProvider);
    final fazendasAsync = ref.watch(fazendaListStreamProvider);
    final safrasAsync = ref.watch(safraListStreamProvider);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              Text(
            widget.existing == null ? 'Nova Produção' : 'Editar Produção',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
            produtosAsync.when(
              data: (produtos) {
                if (!produtos.any((p) => p.id == selectedProduto)) {
                  selectedProduto = null;
                }

                

                return DropdownButtonFormField<String>(
                  value: selectedProduto,
                  items: produtos
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedProduto = val),
                  decoration: const InputDecoration(labelText: 'Produto'),
                  validator: (value) => value == null ? 'Selecione um produto' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro ao carregar produtos: $e'),
            ),

            fazendasAsync.when(
              data: (fazendas) {
                if (!fazendas.any((f) => f.id == selectedFazenda)) {
                  selectedFazenda = null;
                }

                return DropdownButtonFormField<String>(
                  value: selectedFazenda,
                  items: fazendas
                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedFazenda = val),
                  decoration: const InputDecoration(labelText: 'Fazenda'),
                  validator: (value) => value == null ? 'Selecione uma fazenda' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro ao carregar fazendas: $e'),
            ),

            safrasAsync.when(
              data: (safras) {
                if (!safras.any((s) => s.id == selectedSafra)) {
                  selectedSafra = null;
                }

                return DropdownButtonFormField<String>(
                  value: selectedSafra,
                  items: safras
                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nome)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedSafra = val),
                  decoration: const InputDecoration(labelText: 'Safra'),
                  validator: (value) => value == null ? 'Selecione uma safra' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro ao carregar safras: $e'),
            ),

            TextFormField(
              initialValue: quantidade?.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              validator: (value) {
                final q = int.tryParse(value ?? '');
                if (q == null || q <= 0) return 'Informe uma quantidade válida';
                return null;
              },
              onSaved: (val) => quantidade = int.tryParse(val ?? ''),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  final user = ref.read(authProvider);
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Usuário não autenticado")),
    );
    return;
  }

  final producao = Producao(
    id: widget.existing?.id ?? '',
    produto: selectedProduto!,
    quantidade: quantidade!,
    fazenda: selectedFazenda!,
    safra: selectedSafra!,
    uid: user.uid, // precisa ter esse campo na entidade
  );

  try {
    if (widget.existing == null) {
      // 1. Cadastrar produção
      final docRef = await repo.addProducaoRetornandoRef(producao);

      // 2. Registrar no estoque
      await repo.registrarProducaoEstoque(producao.copyWith(id: docRef.id));

    } else {
      // Atualizar produção
      await repo.updateProducao(producao);
    }

    if (context.mounted) Navigator.of(context).pop();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar produção: $e')),
      );
    }
  }
},

              child: Text(widget.existing == null ? 'Cadastrar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

