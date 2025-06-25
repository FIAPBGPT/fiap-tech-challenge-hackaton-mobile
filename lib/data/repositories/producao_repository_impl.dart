import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiap_farms_app/domain/entities/producao.dart';
import 'package:fiap_farms_app/domain/entities/estoque.dart';
import 'package:fiap_farms_app/domain/repositories/estoque_repository.dart';
import 'package:fiap_farms_app/domain/repositories/producao_repository.dart';

class ProducaoRepositoryImpl implements ProducaoRepository {
  final FirebaseFirestore firestore;
  final EstoqueRepository estoqueRepo;

  ProducaoRepositoryImpl(this.firestore, this.estoqueRepo);

  @override
@override
  Future<void> addProducao(Producao p) async {
    final docRef = firestore.collection('producoes').doc();
    await docRef.set(p.toMap(docRef.id));
    final producaoComId = p.copyWith(id: docRef.id);
    print('Produção adicionada com id: ${docRef.id}'); // DEBUG
    await estoqueRepo.registrarEntradaProducao(producaoComId);
    print(
        'Registro de entrada no estoque criado para produção: ${docRef.id}'); // DEBUG
  }


  Future<void> updateProducao(Producao antiga, Producao atualizada) async {
    // Atualiza o documento da produção
    await firestore
        .collection('producoes')
        .doc(atualizada.id)
        .update(atualizada.toMap());

    // Calcula a diferença entre a quantidade nova e a antiga
    final diff = atualizada.quantidade - antiga.quantidade;

    if (diff != 0) {
      // Cria um registro de movimentação no estoque para refletir a alteração
      final docRef = firestore.collection('estoque').doc();

      final movimentacao = Estoque(
        id: docRef.id,
        produtoId: atualizada.produto,
        safraId: atualizada.safra,
        fazendaId: atualizada.fazenda,
        quantidade: diff.abs(),
        tipo: diff > 0
            ? 'entrada'
            : 'saida', // entrada se aumentou, saída se diminuiu
        data: DateTime.now(),
        observacao: 'Ajuste por atualização da produção ${atualizada.id}',
      );

      await docRef.set(movimentacao.toMap());
    }
}



  @override
  Future<void> deleteProducao(Producao p) async {
    await firestore.collection('producoes').doc(p.id).delete();
    await estoqueRepo.removerEntradaProducao(p);
  }

  @override
  Stream<List<Producao>> watchAllProducoes() {
    return firestore.collection('producoes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Producao.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
