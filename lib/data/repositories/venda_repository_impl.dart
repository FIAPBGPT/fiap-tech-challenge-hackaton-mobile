import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/domain/entities/venda.dart';
import 'package:fiap_farms_app/domain/repositories/venda_repository.dart';
import '../../domain/repositories/estoque_repository.dart';

class VendaRepositoryImpl implements VendaRepository {
  final FirebaseFirestore firestore;
  final EstoqueRepository estoqueRepo;

  VendaRepositoryImpl(this.firestore, this.estoqueRepo);

  @override
  Future<void> addVenda(Venda venda) async {
    for (final item in venda.itens) {
      final saldo = await estoqueRepo.consultarSaldo(
        produtoId: item.produtoId,
        safraId: item.safraId,
        fazendaId: item.fazendaId,
      );

      if (saldo < item.quantidade) {
        throw Exception('Saldo insuficiente para o produto ${item.produtoId}');
      }
    }

    final docRef = firestore.collection('vendas').doc();
    await docRef.set(venda.toMap(docRef.id));
    await estoqueRepo.registrarVendaEstoque(venda.copyWith(id: docRef.id));
  }

  @override
  Future<void> deleteVenda(Venda venda) async {
    await firestore.collection('vendas').doc(venda.id).delete();
    await estoqueRepo.reabastecerEstoqueVenda(venda);
  }

  @override
Future<void> updateVenda(Venda vendaNova) async {
    final docRef = firestore.collection('vendas').doc(vendaNova.id);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception('Venda não encontrada');
    }

    final vendaAntiga = Venda.fromMap(doc.data()!, doc.id);

    // Para cada item da venda, calcular a diferença de quantidade entre nova e antiga
    for (final itemNovo in vendaNova.itens) {
      // Procurar o item correspondente na venda antiga (produtos, fazendas e safras devem bater)
      final itemAntigo = vendaAntiga.itens.firstWhere(
        (i) =>
            i.produtoId == itemNovo.produtoId &&
            i.fazendaId == itemNovo.fazendaId &&
            i.safraId == itemNovo.safraId,
        orElse: () => null
            as dynamic, // workaround for nullable, but better to use try-catch or where
      );

      final quantidadeAntiga = itemAntigo != null ? itemAntigo.quantidade : 0;
      final diff = itemNovo.quantidade - quantidadeAntiga;

      if (diff > 0) {
        // Se aumentou a quantidade, checar estoque disponível
        final saldo = await estoqueRepo.consultarSaldo(
          produtoId: itemNovo.produtoId,
          safraId: itemNovo.safraId,
          fazendaId: itemNovo.fazendaId,
        );

        if (saldo < diff) {
          throw Exception(
              'Saldo insuficiente para o produto ${itemNovo.produtoId}');
        }
      }
    }

    // Atualizar a venda no Firestore
    await docRef.update(vendaNova.toMap(vendaNova.id));

    // Atualizar o estoque para refletir as mudanças
    // Primeiro, reabastece a quantidade antiga no estoque (como se removesse a venda antiga)
    await estoqueRepo.reabastecerEstoqueVenda(vendaAntiga);

    // Depois, registra o estoque conforme a nova venda
    await estoqueRepo.registrarVendaEstoque(vendaNova);
  }


  @override
  Stream<List<Venda>> watchAllVendas() {
    return firestore.collection('vendas').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Venda.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
