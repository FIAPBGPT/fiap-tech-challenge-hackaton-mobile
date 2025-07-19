import 'package:fiap_farms_app/presentation/widgets/goals_widget.dart';
import 'package:fiap_farms_app/presentation/widgets/locations_widget.dart';
import 'package:fiap_farms_app/presentation/widgets/sales_widget.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            LocationsWidget(),
            SalesWidget(),
            GoalsWidget(),
          ],
        ),
      ),
    );
  }
}
