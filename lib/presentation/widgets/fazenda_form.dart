import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/fazenda.dart';
import '../../core/providers/fazenda_provider.dart';
import 'package:uuid/uuid.dart';

class FazendaForm extends ConsumerStatefulWidget {
  final Fazenda? existing;

  const FazendaForm({super.key, this.existing});

  @override
  ConsumerState<FazendaForm> createState() => _FazendaFormState();
}

class _FazendaFormState extends ConsumerState<FazendaForm> {
  final _nomeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = widget.existing;
    if (f != null) {
      _nomeController.text = f.nome;
      _estadoController.text = f.estado;
      _latController.text = f.latitude.toString();
      _longController.text = f.longitude.toString();
    }
  }

  Future<void> _submit() async {
    final repo = ref.read(fazendaRepositoryProvider);

    final fazenda = Fazenda(
      id: widget.existing?.id ?? const Uuid().v4(),
      nome: _nomeController.text.trim(),
      estado: _estadoController.text.trim(),
      latitude: double.parse(_latController.text.trim()),
      longitude: double.parse(_longController.text.trim()),
    );

    if (widget.existing != null) {
      await repo.updateFazenda(fazenda);
    } else {
      await repo.createFazenda(fazenda);
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
            widget.existing == null ? 'Nova Fazenda' : 'Editar Fazenda',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
                labelText: 'Nome', labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
          ),
          TextField(
            controller: _estadoController,
            decoration: const InputDecoration(
                labelText: 'Estado',
                labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
          ),
          TextField(
            controller: _latController,
            decoration: const InputDecoration(
                labelText: 'Latitude',
                labelStyle: TextStyle(color: Colors.white)),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
          ),
          TextField(
            controller: _longController,
            decoration: const InputDecoration(
                labelText: 'Longitude',
                labelStyle: TextStyle(color: Colors.white)),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.existing != null ? 'Atualizar Fazenda' : 'Cadastrar Fazenda'),
        ),
      ],
    ),
  );
}

}
