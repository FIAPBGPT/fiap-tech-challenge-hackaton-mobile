import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/venda.dart';
import '../../core/providers/estoque_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/safra_provider.dart';
import '../../core/providers/fazenda_provider.dart';
import '../../core/providers/venda_provider.dart';
import '../../domain/entities/estoque.dart';

class VendaForm extends ConsumerStatefulWidget {
  final Venda? existing;
  final VoidCallback? onSuccess;

  const VendaForm({this.existing, this.onSuccess, super.key});

  @override
  ConsumerState<VendaForm> createState() => _VendaFormState();
}

class _VendaFormState extends ConsumerState<VendaForm> {
  final _formKey = GlobalKey<FormState>();

  String produtoId = '';
  String? safraId;
  String? fazendaId;

  final _quantidadeController = TextEditingController();
  final _valorController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final v = widget.existing!;
      produtoId = v.produtoId;
      safraId = v.safraId.isNotEmpty ? v.safraId : null;
      fazendaId = v.fazendaId.isNotEmpty ? v.fazendaId : null;
      _quantidadeController.text = v.quantidade.toString();
      _valorController.text = v.valor.toString();
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final repoVenda = ref.read(vendaRepositoryProvider);
    final repoEstoque = ref.read(estoqueRepositoryProvider);

    try {
      var novaVenda = Venda(
        id: widget.existing?.id ?? const Uuid().v4(),
        produtoId: produtoId,
        safraId: safraId ?? '',
        fazendaId: fazendaId ?? '',
        quantidade: double.parse(_quantidadeController.text),
        valor: double.parse(_valorController.text),
        uid: '', // Exemplo: FirebaseAuth.instance.currentUser?.uid ?? ''
        data: widget.existing?.data ?? DateTime.now(),
      );

      // Se for edição, reabastece o estoque com os dados antigos
      if (widget.existing != null) {
        await repoEstoque.adicionarEstoque(
          Estoque(
            id: const Uuid().v4(),
            produtoId: widget.existing!.produtoId,
            safraId: widget.existing!.safraId.isEmpty ? null : widget.existing!.safraId,
            fazendaId: widget.existing!.fazendaId.isEmpty ? null : widget.existing!.fazendaId,
            quantidade: widget.existing!.quantidade,
            tipo: 'entrada',
            observacao: 'Reabastecimento por edição da venda ID: ${widget.existing!.id}',
            data: DateTime.now(),
          ),
        );
      }

      // Verifica saldo de estoque atual
      final saldo = await repoEstoque.consultarSaldo(
        produtoId: novaVenda.produtoId,
        safraId: novaVenda.safraId.isEmpty ? null : novaVenda.safraId,
        fazendaId: novaVenda.fazendaId.isEmpty ? null : novaVenda.fazendaId,
      );

      if (novaVenda.quantidade > saldo) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saldo insuficiente no estoque. Saldo atual: $saldo')),
          );
        }
        setState(() => _loading = false);
        return;
      }

      // Salvar venda (editar ou criar)
      if (widget.existing != null) {
        await repoVenda.atualizarVenda(novaVenda.id, novaVenda);
      } else {
        await repoVenda.adicionarVenda(novaVenda);
      }

      // Registrar saída no estoque
      await repoEstoque.adicionarEstoque(
        Estoque(
          id: const Uuid().v4(),
          produtoId: novaVenda.produtoId,
          safraId: novaVenda.safraId.isEmpty ? null : novaVenda.safraId,
          fazendaId: novaVenda.fazendaId.isEmpty ? null : novaVenda.fazendaId,
          quantidade: novaVenda.quantidade,
          tipo: 'saida',
          observacao: 'Venda ID: ${novaVenda.id}',
          data: DateTime.now(),
        ),
      );

      if (context.mounted) {
        widget.onSuccess?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar venda: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(productListStreamProvider);
    final safrasAsync = ref.watch(safraListStreamProvider);
    final fazendasAsync = ref.watch(fazendaListStreamProvider);

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
          produtosAsync.when(
            data: (produtos) {
              // Garantir que o produtoId esteja na lista
              if (produtoId.isNotEmpty && !produtos.any((p) => p.id == produtoId)) {
                produtoId = '';
              }

              return DropdownButtonFormField<String>(
                value: produtoId.isNotEmpty ? produtoId : null,
                decoration: const InputDecoration(labelText: 'Produto'),
                items: produtos
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
                    .toList(),
                onChanged: (val) => setState(() => produtoId = val ?? ''),
                validator: (v) => v == null || v.isEmpty ? 'Selecione um produto' : null,
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Erro ao carregar produtos: $e'),
          ),
          safrasAsync.when(
            data: (safras) {
              if (safraId != null && !safras.any((s) => s.id == safraId)) {
                safraId = null;
              }

              return DropdownButtonFormField<String>(
                value: safraId,
                decoration: const InputDecoration(labelText: 'Safra'),
                items: safras
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nome)))
                    .toList(),
                onChanged: (val) => setState(() => safraId = val),
                // safra pode ser opcional, então sem validator
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Erro ao carregar safras: $e'),
          ),
          fazendasAsync.when(
            data: (fazendas) {
              if (fazendaId != null && !fazendas.any((f) => f.id == fazendaId)) {
                fazendaId = null;
              }

              return DropdownButtonFormField<String>(
                value: fazendaId,
                decoration: const InputDecoration(labelText: 'Fazenda'),
                items: fazendas
                    .map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome)))
                    .toList(),
                onChanged: (val) => setState(() => fazendaId = val),
                // fazenda pode ser opcional, se for, não obrigar validação
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Erro ao carregar fazendas: $e'),
          ),
          TextFormField(
            controller: _quantidadeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Quantidade'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a quantidade';
              final q = double.tryParse(v);
              if (q == null || q <= 0) return 'Quantidade inválida';
              return null;
            },
          ),
          TextFormField(
            controller: _valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Valor'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe o valor';
              final val = double.tryParse(v);
              if (val == null || val < 0) return 'Valor inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.existing != null ? 'Atualizar' : 'Cadastrar'),
                ),
        ]),
      ),
    );
  }
}
