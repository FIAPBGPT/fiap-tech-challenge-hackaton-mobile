import 'package:fiap_farms_app/presentation/pages/dashboard_page.dart';
import 'package:fiap_farms_app/presentation/pages/estoque_page.dart';
import 'package:fiap_farms_app/presentation/pages/fazenda_page.dart';
import 'package:fiap_farms_app/presentation/pages/meta_page.dart';
import 'package:fiap_farms_app/presentation/pages/producao_page.dart';
import 'package:fiap_farms_app/presentation/pages/safra_page.dart';
import 'package:fiap_farms_app/presentation/pages/venda_page.dart';
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
    setState(() {
      currentSection = section;
    });
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('FIAP Farms', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
  title: const Text('Dashboard'),
  onTap: () => _onSelectSection(HomeSection.dashboard),
),
            ListTile(
              title: const Text('Produtos'),
              onTap: () => _onSelectSection(HomeSection.produtos),
            ),
            ListTile(
              title: const Text('Estoque'),
              onTap: () => _onSelectSection(HomeSection.estoque),
            ),
            ListTile(
              title: const Text('Vendas'),
              onTap: () => _onSelectSection(HomeSection.vendas),
            ),
            ListTile(
              title: const Text('Produção'),
              onTap: () => _onSelectSection(HomeSection.producao),
            ),
            ListTile(
              title: const Text('Metas'),
              onTap: () => _onSelectSection(HomeSection.metas),
            ),
            ListTile(
              title: const Text('Fazendas'),
              onTap: () => _onSelectSection(HomeSection.fazendas),
            ),
            ListTile(
              title: const Text('Safras'),
              onTap: () => _onSelectSection(HomeSection.safras),
            ),
            const Divider(),
            ListTile(
              title: const Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _buildSection(currentSection),
    );
  }
}
