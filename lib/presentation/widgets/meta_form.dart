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
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
            produtosAsync.when(
              data: (produtos) {
                if (produto != null && !produtos.any((p) => p.id == produto)) produto = null;
                return DropdownButtonFormField<String>(
                  value: produto,
                  items: produtos
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
                      .toList(),
                  onChanged: (v) => setState(() => produto = v),
                  decoration: const InputDecoration(labelText: 'Produto'),
                  validator: (v) => v == null || v.isEmpty ? 'Selecione um produto' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro produtos: $e'),
            ),

            safraAsync.when(
              data: (safras) {
                if (safra != null && !safras.any((s) => s.id == safra)) safra = null;
                return DropdownButtonFormField<String>(
                  value: safra,
                  items: safras
                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.nome)))
                      .toList(),
                  onChanged: (v) => setState(() => safra = v),
                  decoration: const InputDecoration(labelText: 'Safra'),
                  validator: (v) => v == null || v.isEmpty ? 'Selecione uma safra' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro safras: $e'),
            ),

            fazendaAsync.when(
              data: (fazendas) {
                if (fazenda != null && !fazendas.any((f) => f.id == fazenda)) fazenda = null;
                return DropdownButtonFormField<String>(
                  value: fazenda,
                  items: fazendas
                      .map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome)))
                      .toList(),
                  onChanged: (v) => setState(() => fazenda = v),
                  decoration: const InputDecoration(labelText: 'Fazenda'),
                  validator: (v) => v == null || v.isEmpty ? 'Selecione uma fazenda' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro fazendas: $e'),
            ),

            TextFormField(
              initialValue: valorStr,
              decoration: const InputDecoration(labelText: 'Valor da Meta'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final val = double.tryParse(v ?? '');
                if (val == null || val <= 0) return 'Informe um valor válido';
                return null;
              },
              onSaved: (v) => valorStr = v!.trim(),
            ),

           DropdownButtonFormField<String>(
  value: tipo,
  decoration: const InputDecoration(labelText: 'Tipo de Meta'),
  items: const [
    DropdownMenuItem(value: 'producao', child: Text('Produção')),
    DropdownMenuItem(value: 'vendas', child: Text('Venda')),  
  ],
  onChanged: (v) => setState(() => tipo = v ?? 'producao'),
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
              child: Text(widget.existingMeta == null ? 'Cadastrar' : 'Atualizar'),
            ),
          ]),
        ),
      ),
    );
  }
}
