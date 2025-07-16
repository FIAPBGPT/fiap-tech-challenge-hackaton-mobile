import 'package:fiap_farms_app/core/providers/notification_provider.dart';
import 'package:fiap_farms_app/presentation/pages/dashboard_page.dart';
import 'package:fiap_farms_app/presentation/pages/estoque_page.dart';
import 'package:fiap_farms_app/presentation/pages/fazenda_page.dart';
import 'package:fiap_farms_app/presentation/pages/meta_page.dart';
import 'package:fiap_farms_app/presentation/pages/producao_page.dart';
import 'package:fiap_farms_app/presentation/pages/safra_page.dart';
import 'package:fiap_farms_app/presentation/pages/venda_page.dart';
import 'package:fiap_farms_app/presentation/widgets/main_menu/main_menu.dart';
import 'package:fiap_farms_app/presentation/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_page.dart';
import 'home_sections.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  HomeSection currentSection = HomeSection.dashboard;

  Widget _buildSection(HomeSection section) {
    switch (section) {
      case HomeSection.dashboard:
        return const DashboardPage();
      case HomeSection.produtos:
        return ProductPage();
      case HomeSection.fazendas:
        return FazendaPage();
      case HomeSection.safras:
        return const SafraPage();
      case HomeSection.producao:
        return const ProducaoPage();
      case HomeSection.metas:
        return const MetaPage();
      case HomeSection.vendas:
        return VendaPage();
      case HomeSection.estoque:
        return const EstoquePage();
      default:
        return const Center(child: Text("Página em construção"));
    }
  }

  void _onSelectSection(HomeSection section) {
    setState(() => currentSection = section);

    Navigator.pop(context); // fecha o drawer
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  String _userName() {
    return (FirebaseAuth.instance.currentUser?.email ?? '').split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    final notificacoesAsync = ref.watch(notificacaoProvider);
    final notificacoesLidas = ref.watch(notificacoesLidasProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'FIAP Farms • ${currentSection.name.toUpperCase()}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF97133E),
        actions: [
          notificacoesAsync.when(
            data: (notificacoes) {
              final notificationCount = notificacoes.length;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    color: Colors.white,
                    onPressed: () {
                      ref.read(notificacoesLidasProvider.state).state = true;
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(
                              notificationCount > 0
                                  ? 'Notificação${notificationCount > 1 ? 's' : ''}'
                                  : 'Sem notificações',
                              style: const TextStyle(
                                color: Color(0xFF97133E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: notificationCount > 0
                                ? SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: notificacoes.map((n) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF0F5),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ListTile(
                                            leading: const Icon(
                                                Icons.attach_money,
                                                size: 40,
                                                color: Color(0xFF59734A)),
                                            title: Text(
                                              'Meta Batida: ${n.fazenda}',
                                              style: const TextStyle(
                                                color: Color(0xFF97133E),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Produto: ${n.produto}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Valor: R\$ ${n.valorVenda.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                : const Text(
                                    'Nenhuma notificação no momento.',
                                    style: TextStyle(color: Color(0xFF59734A)),
                                  ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Color(0xFF97133E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  if (notificationCount > 0 && !notificacoesLidas)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              ),
            ),
            error: (err, _) => const Icon(Icons.error, color: Colors.red),
          ),
        ],
      ),
      drawer: MainMenu(
        userName: _userName(),
        selectionHandler: _onSelectSection,
        logoutHandler: _logout,
      ),
      body: _buildSection(currentSection),
    );
  }
}
