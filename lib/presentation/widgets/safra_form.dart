import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/safra.dart';
import '../../core/providers/safra_provider.dart';
import 'package:uuid/uuid.dart';

class SafraForm extends ConsumerStatefulWidget {
  final Safra? existing;
  const SafraForm({super.key, this.existing});

  @override
  ConsumerState<SafraForm> createState() => _SafraFormState();
}

class _SafraFormState extends ConsumerState<SafraForm> {
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nomeController.text = widget.existing!.nome;
      _valorController.text = widget.existing!.valor;
    }
  }

  Future<void> _submit() async {
    final repo = ref.read(safraRepositoryProvider);

    final safra = Safra(
      id: widget.existing?.id ?? const Uuid().v4(),
      nome: _nomeController.text.trim(),
      valor: _valorController.text.trim(),
    );

    if (widget.existing != null) {
      await repo.updateSafra(safra);
    } else {
      await repo.createSafra(safra);
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: 16,
      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            widget.existing == null ? 'Nova Safra' : 'Editar Safra',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
        TextField(
          controller: _nomeController,
          decoration: const InputDecoration(labelText: 'Nome da Safra'),
        ),
        TextField(
          controller: _valorController,
          decoration: const InputDecoration(labelText: 'Valor'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.existing != null ? 'Atualizar Safra' : 'Cadastrar Safra'),
        ),
      ],
    ),
  );
}

}
