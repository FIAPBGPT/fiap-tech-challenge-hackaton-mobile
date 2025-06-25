import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.dashboard, size: 64, color: Colors.green),
          SizedBox(height: 20),
          Text(
            'Dashboard FIAP Farms',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Resumo de vendas, produção e metas.'),
        ],
      ),
    );
  }
}
