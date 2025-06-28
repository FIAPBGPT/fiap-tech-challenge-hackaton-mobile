import 'package:fiap_farms_app/core/providers/auth_provider.dart';
import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/producao_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/safra_provider.dart';
import 'package:fiap_farms_app/domain/entities/producao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProducaoForm extends ConsumerStatefulWidget {
  final Producao? producao;
  const ProducaoForm({super.key, this.producao});

  @override
  ConsumerState<ProducaoForm> createState() => _ProducaoFormState();
}

class _ProducaoFormState extends ConsumerState<ProducaoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _qController;
  String? produtoId;
  String? safraId;
  String? fazendaId;

  @override
  void initState() {
    super.initState();
    final p = widget.producao;
    _qController = TextEditingController(text: p?.quantidade.toString() ?? '');
    produtoId = p?.produto;
    safraId = p?.safra;
    fazendaId = p?.fazenda;
  }

  @override
  Widget build(BuildContext context) {
    final produtos = ref.watch(productListStreamProvider);
    final fazendas = ref.watch(fazendaListStreamProvider);
    final safras = ref.watch(safraListStreamProvider);
    final auth = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: produtoId,
            hint: const Text('Selecione o produto'),
            items: produtos.value
                    ?.map((p) =>
                        DropdownMenuItem(value: p.id, child: Text(p.nome)))
                    .toList() ??
                [],
            onChanged: (v) => setState(() => produtoId = v),
            validator: (v) =>
                v == null || v.isEmpty ? 'Produto obrigatório' : null,
          ),
          DropdownButtonFormField<String>(
            value: safraId,
            hint: const Text('Selecione a safra'),
            items: safras.value
                    ?.map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.nome)))
                    .toList() ??
                [],
            onChanged: (v) => setState(() => safraId = v),
            validator: (v) =>
                v == null || v.isEmpty ? 'Safra obrigatória' : null,
          ),
          DropdownButtonFormField<String>(
            value: fazendaId,
            hint: const Text('Selecione a fazenda'),
            items: fazendas.value
                    ?.map((f) =>
                        DropdownMenuItem(value: f.id, child: Text(f.nome)))
                    .toList() ??
                [],
            onChanged: (v) => setState(() => fazendaId = v),
            validator: (v) =>
                v == null || v.isEmpty ? 'Fazenda obrigatória' : null,
          ),
          TextFormField(
            controller: _qController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade'),
            validator: (v) {
              final q = double.tryParse(v ?? '');
              if (q == null || q <= 0) return 'Informe uma quantidade válida';
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final quantidade = double.tryParse(_qController.text.trim()) ?? 0;

              final novaProducao = Producao(
                id: widget.producao?.id ?? '',
                produto: produtoId!,
                safra: safraId!,
                fazenda: fazendaId!,
                quantidade: quantidade,
                data: widget.producao?.data ?? DateTime.now(),
                uid: auth?.uid ?? '', // <-- Adiciona o UID do usuário
              );

              final repo = ref.read(producaoRepositoryProvider);
              if (widget.producao == null) {
                await repo.addProducao(novaProducao);
              } else {
                await repo.updateProducao(widget.producao!, novaProducao);
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: Text(widget.producao == null ? 'Salvar' : 'Atualizar'),
          ),
        ]),
      ),
    );
  }
}
