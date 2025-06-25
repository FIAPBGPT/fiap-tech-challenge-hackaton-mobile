import 'package:fiap_farms_app/core/providers/estoque_provider.dart';
import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/core/providers/venda_provider.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendaForm extends ConsumerStatefulWidget {
  final Venda? existing;
  final VoidCallback onSuccess;

  const VendaForm({Key? key, this.existing, required this.onSuccess})
      : super(key: key);

  @override
  ConsumerState<VendaForm> createState() => _VendaFormState();
}

class _VendaFormState extends ConsumerState<VendaForm> {
  final _formKey = GlobalKey<FormState>();

  String? produtoId;
  String? fazendaId;
  String? safraId;
  double? quantidade;
  double saldo = 0;
  DateTime data = DateTime.now();
  bool carregando = false;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    if (existing != null && existing.itens.isNotEmpty) {
      final item = existing.itens.first;
      produtoId = item.produtoId;
      safraId = item.safraId;
      fazendaId = item.fazendaId;
      quantidade = item.quantidade;
      data = existing.data;
    }

    _consultarSaldo();
  }

  Future<void> _consultarSaldo() async {
    if (produtoId != null) {
      final resultado =
          await ref.read(estoqueRepositoryProvider).consultarSaldo(
                produtoId: produtoId!,
                safraId: safraId,
                fazendaId: fazendaId,
              );
      setState(() => saldo = resultado);
    } else {
      setState(() => saldo = 0);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (produtoId == null || quantidade == null || quantidade! <= 0) return;

    if (quantidade! > saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estoque insuficiente. Saldo: $saldo')),
      );
      return;
    }

    final venda = Venda(
      id: widget.existing?.id ?? '',
      itens: [
        VendaItem(
          produtoId: produtoId!,
          quantidade: quantidade!,
          safraId: safraId,
          fazendaId: fazendaId,
        )
      ],
      data: data,
    );

    setState(() => carregando = true);
    try {
      if (widget.existing == null) {
        await ref.read(vendaRepositoryProvider).addVenda(venda);
      } else {
        await ref.read(vendaRepositoryProvider).updateVenda(venda);
      }
      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(produtoMapProvider);
    final fazendasAsync = ref.watch(fazendaListStreamProvider);
    final safrasAsync = ref.watch(safraListStreamProvider);

    final isEditing = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            produtosAsync.when(
              data: (produtos) => DropdownButtonFormField<String>(
                value: produtoId,
                decoration: const InputDecoration(labelText: 'Produto'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Selecione')),
                  ...produtos.entries.map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                ],
                validator: (v) => v == null ? 'Selecione o produto' : null,
                onChanged: isEditing
                    ? null
                    : (v) {
                        setState(() => produtoId = v);
                        _consultarSaldo();
                      },
),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erro ao carregar produtos: $e'),
            ),
            const SizedBox(height: 8),
            fazendasAsync.when(
              data: (fazendas) => DropdownButtonFormField<String>(
                value: fazendaId,
                decoration: const InputDecoration(labelText: 'Fazenda'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...fazendas.map(
                      (f) => DropdownMenuItem(value: f.id, child: Text(f.nome)))
                ],
                validator: (v) => v == null ? 'Selecione a fazenda' : null,
                onChanged: isEditing
                    ? null
                    : (v) {
                        setState(() => fazendaId = v);
                        _consultarSaldo();
                      },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erro fazendas: $e'),
            ),
            const SizedBox(height: 8),
            safrasAsync.when(
              data: (safras) => DropdownButtonFormField<String>(
                value: safraId,
                decoration: const InputDecoration(labelText: 'Safra'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...safras.map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.nome)))
                ],
                validator: (v) => v == null ? 'Selecione a safra' : null,
                onChanged: isEditing
                    ? null
                    : (v) {
                        setState(() => safraId = v);
                        _consultarSaldo();
                      },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erro safras: $e'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue:
                  quantidade != null ? quantidade!.toStringAsFixed(2) : '',
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final q = double.tryParse(v ?? '');
                if (q == null || q <= 0) return 'Quantidade inválida';
                if (q > saldo) return 'Excede o saldo disponível ($saldo)';
                return null;
              },
              onSaved: (v) => quantidade = double.tryParse(v ?? ''),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saldo disponível: ${saldo.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (carregando ||
                      produtoId == null ||
                      quantidade == null ||
                      quantidade! > saldo)
                  ? null
                  : _salvar,
              child: carregando
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEditing ? 'Atualizar Venda' : 'Registrar Venda'),
            )
          ],
        ),
      ),
    );
  }
}
