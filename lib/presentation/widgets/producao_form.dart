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
          ),
          TextFormField(
            controller: _qController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantidade = double.tryParse(_qController.text) ?? 0;
              final p = Producao(
                id: widget.producao?.id ?? '',
                produto: produtoId ?? '',
                safra: safraId,
                fazenda: fazendaId,
                quantidade: quantidade,
                data: widget.producao?.data ?? DateTime.now(),
              );
              if (widget.producao == null) {
                await ref.read(producaoRepositoryProvider).addProducao(p);
              } else {
                await ref
                    .read(producaoRepositoryProvider)
                    .updateProducao(widget.producao!, p);
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
