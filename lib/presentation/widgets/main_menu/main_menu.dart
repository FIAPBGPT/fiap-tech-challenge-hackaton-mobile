import 'package:flutter/material.dart';
import 'package:fiap_farms_app/presentation/pages/home_sections.dart';
import './main_menu_item.dart';
import './main_menu_header.dart';

class MainMenu extends StatelessWidget {
  final String userName;
  final Function selectionHandler;
  final Function logoutHandler;

  const MainMenu({
    super.key,
    required this.selectionHandler,
    required this.logoutHandler,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: BoxBorder.all(style: BorderStyle.none),
      backgroundColor: Color(0xFFF1EBD9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          MainMenuHeader(userName: userName),
          MainMenuItem(
            label: 'Home',
            icon: Icons.home,
            action: () => selectionHandler(HomeSection.dashboard),
          ),
          MainMenuItem(
            label: 'Produtos',
            action: () => selectionHandler(HomeSection.produtos),
          ),
          MainMenuItem(
            label: 'Estoque',
            action: () => selectionHandler(HomeSection.estoque),
          ),
          MainMenuItem(
            label: 'Vendas',
            action: () => selectionHandler(HomeSection.vendas),
          ),
          MainMenuItem(
            label: 'Produção',
            action: () => selectionHandler(HomeSection.producao),
          ),
          MainMenuItem(
            label: 'Metas',
            action: () => selectionHandler(HomeSection.metas),
          ),
          MainMenuItem(
            label: 'Fazendas',
            action: () => selectionHandler(HomeSection.fazendas),
          ),
          MainMenuItem(
            label: 'Safras',
            action: () => selectionHandler(HomeSection.safras),
          ),
          const Divider(
            color: Color(0xFFDDCCBB),
          ),
          MainMenuItem(
            label: 'Fechar',
            action: () => logoutHandler(),
          ),
        ],
      ),
    );
  }
}
