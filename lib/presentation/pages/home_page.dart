import 'package:fiap_farms_app/presentation/pages/dashboard_page.dart';
import 'package:fiap_farms_app/presentation/pages/estoque_page.dart';
import 'package:fiap_farms_app/presentation/pages/fazenda_page.dart';
import 'package:fiap_farms_app/presentation/pages/meta_page.dart';
import 'package:fiap_farms_app/presentation/pages/producao_page.dart';
import 'package:fiap_farms_app/presentation/pages/safra_page.dart';
import 'package:fiap_farms_app/presentation/pages/venda_page.dart';
import 'package:fiap_farms_app/presentation/widgets/main_menu/main_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_page.dart';
import 'home_sections.dart';

// Adicione os imports das demais páginas depois
// import 'estoque_page.dart'; ...

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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FIAP Farms • ${currentSection.name.toUpperCase()}'),
      ),
      drawer: MainMenu(
        userName: 'Usuário dos Anjos', // TODO: Pegar o nome do usuário logado
        selectionHandler: _onSelectSection,
      ),
      body: _buildSection(currentSection),
    );
  }
}
