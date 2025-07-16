import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/meta.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/fazenda.dart';
import '../../domain/entities/safra.dart';
import '../../core/providers/meta_provider.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/fazenda_provider.dart';
import '../../core/providers/safra_provider.dart';

class MetaForm extends ConsumerStatefulWidget {
  final Meta? existingMeta;
  const MetaForm({this.existingMeta, super.key});

  @override
  ConsumerState<MetaForm> createState() => _MetaFormState();
}

class _MetaFormState extends ConsumerState<MetaForm> {
  final _formKey = GlobalKey<FormState>();

  String? produto;
  String? safra;
  String? fazenda;
  String tipo = 'producao';
  String valorStr = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingMeta != null) {
      final m = widget.existingMeta!;
      produto = m.produto;
      safra = m.safra;
      fazenda = m.fazenda;
      tipo = m.tipo;
      valorStr = m.valor.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(metaRepositoryProvider);
    final user = ref.watch(authProvider);

    final produtosAsync = ref.watch(productListStreamProvider);
    final safraAsync = ref.watch(safraListStreamProvider);
    final fazendaAsync = ref.watch(fazendaListStreamProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(children: [
            Text(
              widget.existingMeta == null ? 'Nova Meta' : 'Editar Meta',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 16),
            produtosAsync.when(
              data: (produtos) {
                if (produto != null && !produtos.any((p) => p.id == produto))
                  produto = null;
                return DropdownButtonFormField<String>(
                  value: produto,
                  dropdownColor: Colors.white,
                  items: produtos
                      .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            p.nome,
                            style: const TextStyle(color: Colors.black),
                          )))
                      .toList(),
                  onChanged: (v) => setState(() => produto = v),
                  decoration: const InputDecoration(
                    labelText: 'Produto',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Selecione um produto' : null,
                  style: const TextStyle(color: Colors.black),
                  iconEnabledColor: Colors.black,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro produtos: $e',
                  style: const TextStyle(color: Colors.black)),
            ),
            safraAsync.when(
              data: (safras) {
                if (safra != null && !safras.any((s) => s.id == safra))
                  safra = null;
                return DropdownButtonFormField<String>(
                  value: safra,
                  dropdownColor: Colors.white,
                  items: safras
                      .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            s.nome,
                            style: const TextStyle(color: Colors.black),
                          )))
                      .toList(),
                  onChanged: (v) => setState(() => safra = v),
                  decoration: const InputDecoration(
                    labelText: 'Safra',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Selecione uma safra' : null,
                  style: const TextStyle(color: Colors.black),
                  iconEnabledColor: Colors.black,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro safras: $e',
                  style: const TextStyle(color: Colors.black)),
            ),
            fazendaAsync.when(
              data: (fazendas) {
                if (fazenda != null && !fazendas.any((f) => f.id == fazenda))
                  fazenda = null;
                return DropdownButtonFormField<String>(
                  value: fazenda,
                  dropdownColor: Colors.white,
                  items: fazendas
                      .map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(
                            f.nome,
                            style: const TextStyle(color: Colors.black),
                          )))
                      .toList(),
                  onChanged: (v) => setState(() => fazenda = v),
                  decoration: const InputDecoration(
                    labelText: 'Fazenda',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Selecione uma fazenda' : null,
                  style: const TextStyle(color: Colors.black),
                  iconEnabledColor: Colors.black,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro fazendas: $e',
                  style: const TextStyle(color: Colors.black)),
            ),
            TextFormField(
              initialValue: valorStr,
              decoration: const InputDecoration(
                labelText: 'Valor da Meta',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'Informe um valor válido';
                return null;
              },
              onSaved: (v) => valorStr = v!.trim(),
              style: const TextStyle(color: Colors.black),
            ),
            DropdownButtonFormField<String>(
              value: tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Meta',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              dropdownColor: Colors.white,
              items: const [
                DropdownMenuItem(
                    value: 'producao',
                    child: Text('Produção',
                        style: TextStyle(color: Colors.black))),
                DropdownMenuItem(
                    value: 'vendas',
                    child:
                        Text('Venda', style: TextStyle(color: Colors.black))),
              ],
              onChanged: (v) => setState(() => tipo = v ?? 'producao'),
              style: const TextStyle(color: Colors.black),
              iconEnabledColor: Colors.black,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                _formKey.currentState!.save();

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuário não autenticado')),
                  );
                  return;
                }

                final meta = Meta(
                  id: widget.existingMeta?.id ?? '',
                  produto: produto!,
                  safra: safra!,
                  fazenda: fazenda!,
                  valor: double.parse(valorStr),
                  tipo: tipo,
                  uid: user.uid,
                );

                try {
                  if (widget.existingMeta == null) {
                    await repo.addMeta(meta);
                  } else {
                    await repo.updateMeta(meta.id, meta);
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao salvar meta: $e')),
                  );
                }
              },
              child:
                  Text(widget.existingMeta == null ? 'Cadastrar' : 'Atualizar'),
            ),
          ]),
        ),
      ),
    );
  }
}
