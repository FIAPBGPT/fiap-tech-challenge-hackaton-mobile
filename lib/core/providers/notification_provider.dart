import 'dart:async';

import 'package:fiap_farms_app/core/providers/fazenda_provider.dart';
import 'package:fiap_farms_app/core/providers/meta_provider.dart';
import 'package:fiap_farms_app/core/providers/product_provider.dart';
import 'package:fiap_farms_app/core/providers/venda_provider.dart';
import 'package:fiap_farms_app/domain/entities/notificacao.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificacaoProvider =
    FutureProvider.autoDispose<List<Notificacao>>((ref) async {
  ref.keepAlive(); // Mantém ativo mesmo sem listeners
  final link = ref.keepAlive();

  // Invalida após 5 minutos
  final timer = Timer(const Duration(minutes: 5), () {
    link.close();
  });

  ref.onDispose(() => timer.cancel());

  final vendas = await ref.watch(vendaListStreamProvider.future);
  final metas = await ref.watch(metaListStreamProvider.future);
  final fazendas = await ref.watch(fazendaListStreamProvider.future);
  final produtos = await ref.watch(productListStreamProvider.future);

  return gerarNotificacoes(
    vendas: vendas,
    metas: metas,
    fazendas: fazendas,
    produtos: produtos,
  );
});

final notificacoesLidasProvider = StateProvider<bool>((ref) => false);
