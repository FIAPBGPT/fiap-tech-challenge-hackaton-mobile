import 'package:fiap_farms_app/core/providers/estoque_provider.dart';
import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/core/providers/venda_provider.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/core/providers/auth_provider.dart';
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
  double? valor;
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
      valor = item.valor;
      data = existing.data;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _consultarSaldo());
  }

  Future<void> _consultarSaldo() async {
    if (produtoId != null) {
      double resultado =
          await ref.read(estoqueRepositoryProvider).consultarSaldo(
                produtoId: produtoId!,
                safraId: safraId,
                fazendaId: fazendaId,
              );

      if (widget.existing != null && widget.existing!.itens.isNotEmpty) {
        final antigo = widget.existing!.itens.first;
        final mesmoProduto = antigo.produtoId == produtoId;
        final mesmaSafra = (antigo.safraId ?? '') == (safraId ?? '');
        final mesmaFazenda = (antigo.fazendaId ?? '') == (fazendaId ?? '');

        if (mesmoProduto && mesmaSafra && mesmaFazenda) {
          resultado += antigo.quantidade;
        }
      }

      if (mounted) setState(() => saldo = resultado);
    } else {
      if (mounted) setState(() => saldo = 0);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final user = ref.read(authProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

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
          valor: valor!,
          uid: user.uid,
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
      if (!mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e, stack) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
      print('Erro ao salvar venda: $e\n$stack');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  bool get isFormFilled {
    return produtoId != null &&
        fazendaId != null &&
        safraId != null &&
        quantidade != null &&
        quantidade! > 0 &&
        quantidade! <= saldo &&
        valor != null &&
        valor! > 0;
  }

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(produtoMapProvider);
    final fazendasAsync = ref.watch(fazendaListStreamProvider);
    final safrasAsync = ref.watch(safraListStreamProvider);

    final isEditing = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? 'Nova Venda' : 'Editar Venda',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              produtosAsync.when(
                data: (produtos) {
                  final produtoNome =
                      produtoId != null ? produtos[produtoId] : null;
                  return DropdownButtonFormField<String>(
                    value: produtoId,
                    decoration: const InputDecoration(
                      labelText: 'Produto',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('Selecione',
                              style: TextStyle(color: Colors.white))),
                      ...produtos.entries.map((e) =>
                    DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                style: const TextStyle(color: Colors.white)),
                          ))
                    ],
                    validator: (v) => v == null ? 'Selecione o produto' : null,
                    onChanged: isEditing
                        ? null
                        : (v) {
                            setState(() => produtoId = v);
                            _consultarSaldo();
                          },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erro ao carregar produtos: $e',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              fazendasAsync.when(
                data: (fazendas) => DropdownButtonFormField<String>(
                  value: fazendaId,
                  decoration: const InputDecoration(
                    labelText: 'Fazenda',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  items: [
                    const DropdownMenuItem(
                        value: null,
                        child: Text('Todas',
                            style: TextStyle(color: Colors.white))),
                    ...fazendas.map(
                    (f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(f.nome,
                            style: const TextStyle(color: Colors.white))))
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
                error: (e, _) => Text('Erro fazendas: $e',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              safrasAsync.when(
                data: (safras) => DropdownButtonFormField<String>(
                  value: safraId,
                  decoration: const InputDecoration(
                    labelText: 'Safra',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  items: [
                    const DropdownMenuItem(
                        value: null,
                        child: Text('Todas',
                            style: TextStyle(color: Colors.white))),
                    ...safras.map(
                    (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.nome,
                            style: const TextStyle(color: Colors.white))))
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
                error: (e, _) => Text('Erro safras: $e',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue:
                    quantidade != null ? quantidade!.toStringAsFixed(2) : '',
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final q = double.tryParse(v ?? '');
                  if (q == null || q <= 0) return 'Quantidade inválida';
                  if (q > saldo) return 'Excede o saldo disponível ($saldo)';
                  return null;
                },
                onChanged: (v) =>
                    setState(() => quantidade = double.tryParse(v)),
                onSaved: (v) => quantidade = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: valor != null ? valor!.toStringAsFixed(2) : '',
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final q = double.tryParse(v ?? '');
                  if (q == null || q <= 0) return 'Valor inválido';
                  return null;
                },
                onChanged: (v) => setState(() => valor = double.tryParse(v)),
                onSaved: (v) => valor = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Saldo disponível: ${saldo.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (carregando || !isFormFilled) ? null : _salvar,
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
      ),
    );
  }
}
