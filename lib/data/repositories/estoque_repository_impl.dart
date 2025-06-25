import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/domain/entities/estoque.dart';
import 'package:fiap_farms_app/domain/entities/producao.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/domain/repositories/estoque_repository.dart';

class EstoqueRepositoryImpl implements EstoqueRepository {
  final FirebaseFirestore firestore;
  EstoqueRepositoryImpl({required this.firestore});
  CollectionReference get _col => firestore.collection('estoque');

  // Adiciona um item no estoque, salvando o id do documento Firestore corretamente
  Future<Estoque> adicionarEstoque(Estoque e) async {
    final docRef = _col.doc();
    final data = {
      'produtoId': e.produtoId,
      'safraId': e.safraId,
      'fazendaId': e.fazendaId,
      'quantidade': e.quantidade,
      'tipo': e.tipo,
      'observacao': e.observacao,
      'data': e.data is DateTime ? e.data : DateTime.now(),
    };
    await docRef.set(data);
    return Estoque.fromMap(docRef.id, data);
  }

  // Atualiza um item pelo id
  Future<void> atualizarEstoque(String id, Map<String, dynamic> dados) {
    return _col.doc(id).update(dados);
  }

  // Exclui um item pelo id
  Future<void> excluirEstoque(String id) {
    return _col.doc(id).delete();
  }

  // Consulta saldo atual para produto/safra/fazenda
  Future<double> consultarSaldo({
    required String produtoId,
    String? safraId,
    String? fazendaId,
  }) async {
    Query q = _col.where('produtoId', isEqualTo: produtoId);
    if (safraId != null && safraId.isNotEmpty) q = q.where('safraId', isEqualTo: safraId);
    if (fazendaId != null && fazendaId.isNotEmpty) q = q.where('fazendaId', isEqualTo: fazendaId);

    final snap = await q.get();
    double saldo = 0;
    for (final d in snap.docs) {
      final data = d.data() as Map<String, dynamic>;
      final qtd = (data['quantidade'] as num).toDouble();
      saldo += (data['tipo'] == 'entrada') ? qtd : -qtd;
    }
    return saldo;
  }

  // Registrar entrada no estoque ao adicionar produção
  @override
  Future<Estoque> registrarEntradaProducao(Producao p) async {
    final docRef = firestore.collection('estoque').doc();
    final estoque = Estoque(
      id: docRef.id,
      produtoId: p.produto,
      safraId: p.safra,
      fazendaId: p.fazenda,
      quantidade: p.quantidade,
      tipo: 'entrada',
      data: DateTime.now(),
      observacao: 'Entrada pela produção ${p.id}',
    );
    print('Registrando estoque: $estoque'); // DEBUG
    await docRef.set(estoque.toMap());
    print('Estoque registrado com id: ${docRef.id}'); // DEBUG
    return estoque;
  }

  // Remove entrada do estoque ao excluir produção
  Future<void> removerEntradaProducao(Producao p) async {
    final snapshot = await _col
        .where('produtoId', isEqualTo: p.produto)
        .where('safraId', isEqualTo: p.safra)
        .where('fazendaId', isEqualTo: p.fazenda)
        .where('tipo', isEqualTo: 'entrada')
        .where('observacao', isEqualTo: 'Produção ID: ${p.id}')
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Registrar saída no estoque ao adicionar venda
  Future<List<Estoque>> registrarVendaEstoque(Venda venda) async {
    final List<Estoque> entradas = [];
    for (final item in venda.itens) {
      final docRef = _col.doc();
      final data = {
        'produtoId': item.produtoId,
        'safraId': item.safraId,
        'fazendaId': item.fazendaId,
        'quantidade': item.quantidade.toDouble(),
        'tipo': 'saida',
        'observacao': 'Venda ID: ${venda.id}',
        'data': FieldValue.serverTimestamp(),
      };
      await docRef.set(data);
      entradas
          .add(Estoque.fromMap(docRef.id, {...data, 'data': DateTime.now()}));
    }
    return entradas;
  }

  // Reabastece o estoque ao excluir uma venda (entrada contrária)
  Future<List<Estoque>> reabastecerEstoqueVenda(Venda venda) async {
    final List<Estoque> entradas = [];
    for (final item in venda.itens) {
      final docRef = _col.doc();
      final data = {
        'produtoId': item.produtoId,
        'safraId': item.safraId,
        'fazendaId': item.fazendaId,
        'quantidade': item.quantidade.toDouble(),
        'tipo': 'entrada',
        'observacao': 'Reversão de Venda ID: ${venda.id}',
        'data': FieldValue.serverTimestamp(),
      };
      await docRef.set(data);
      entradas
          .add(Estoque.fromMap(docRef.id, {...data, 'data': DateTime.now()}));
    }
    return entradas;
  }

  // Listar todo o estoque com id correto
  Stream<List<Estoque>> listarEstoque() {
    return _col.snapshots().map((querySnapshot) {
      final lista = <Estoque>[];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final estoque = Estoque.fromMap(doc.id, data);
          lista.add(estoque);
        } catch (e) {
          print('Erro ao converter documento ${doc.id}: $e');
        }
      }
      return lista;
    });
  }

  @override
  Future<Estoque> registrarMovimentacao(Estoque e) async {
    final doc = firestore.collection('estoque').doc();
    final entrada = e.copyWith(id: doc.id, data: e.data);
    await doc.set(entrada.toMap());
    return entrada;
}
}
