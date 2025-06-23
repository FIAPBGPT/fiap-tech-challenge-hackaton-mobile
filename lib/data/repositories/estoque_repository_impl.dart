import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/domain/entities/estoque.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/domain/repositories/estoque_repository.dart';

class EstoqueRepositoryImpl implements EstoqueRepository {
  final FirebaseFirestore firestore;

  EstoqueRepositoryImpl(this.firestore);

  CollectionReference get _col => firestore.collection('estoque');

  @override
  Stream<List<Estoque>> listarEstoque() {
    return _col.snapshots().map((querySnapshot) {
      final lista = <Estoque>[];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          if (data['produtoId'] == null || data['quantidade'] == null || data['tipo'] == null || data['data'] == null) {
            print('Documento ${doc.id} ignorado por falta de campos obrigatórios.');
            continue;
          }
          final estoque = Estoque.fromMap(doc.id, data);
          lista.add(estoque);
        } catch (e, st) {
          print('Erro ao converter documento ${doc.id}: $e\n$st');
        }
      }
      return lista;
    });
  }

  @override
  Future<void> adicionarEstoque(Estoque e) async {
    await _col.add(e.toMap());
  }

  @override
  Future<void> atualizarEstoque(String id, Map<String, dynamic> dados) =>
      _col.doc(id).update(dados);

  @override
  Future<void> excluirEstoque(String id) =>
      _col.doc(id).delete();

  @override
  Future<double> consultarSaldo({required String produtoId, String? safraId, String? fazendaId}) async {
    Query q = _col.where('produtoId', isEqualTo: produtoId);
    if (safraId != null && safraId.isNotEmpty) q = q.where('safraId', isEqualTo: safraId);
    if (fazendaId != null && fazendaId.isNotEmpty) q = q.where('fazendaId', isEqualTo: fazendaId);
    final snap = await q.get();
    final saldo = snap.docs.fold<double>(0.0, (prev, d) {
      final m = d.data();
      if (m == null) return prev;
      final map = m as Map<String, dynamic>;
      final qte = (map['quantidade'] as num).toDouble();
      return prev + (map['tipo'] == 'entrada' ? qte : -qte);
    });
    return saldo;
  }

  // REGISTRAR SAÍDA DE ESTOQUE PARA UMA VENDA
  Future<void> registrarVendaEstoque(venda) async {
    for (final item in venda.itens) {
      final estoqueItem = Estoque(
        id: '', // Firestore vai gerar
        produtoId: item.produtoId,
        safraId: item.safraId ?? '',
        fazendaId: item.fazendaId ?? '',
        quantidade: item.quantidade,
        tipo: 'saida',
        observacao: 'Venda ID: ${venda.id}',
        data: DateTime.now(),
      );
      await adicionarEstoque(estoqueItem);
    }
  }

  // REABASTECER ESTOQUE AO EXCLUIR OU EDITAR UMA VENDA (REVERTENDO A SAÍDA ANTERIOR)
  Future<void> reabastecerEstoqueVenda(venda) async {
    for (final item in venda.itens) {
      final estoqueItem = Estoque(
        id: '',
        produtoId: item.produtoId,
        safraId: item.safraId ?? '',
        fazendaId: item.fazendaId ?? '',
        quantidade: item.quantidade,
        tipo: 'entrada',
        observacao: 'Reabastecimento por edição/exclusão da Venda ID: ${venda.id}',
        data: DateTime.now(),
      );
      await adicionarEstoque(estoqueItem);
    }
  }
}
