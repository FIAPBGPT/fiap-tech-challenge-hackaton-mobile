import 'package:fiap_farms_app/presentation/widgets/locations_widget/percentage_ring.dart';
import 'package:flutter/material.dart';

class StateFarms extends StatelessWidget {
  final String state;
  final double percentage;
  final int farmsNumber;

  const StateFarms({
    super.key,
    required this.state,
    required this.farmsNumber,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PercentageRing(value: percentage),
        Text(
          state,
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF97133E),
              fontWeight: FontWeight.bold),
        ),
        Text(
          "$farmsNumber Fazendas",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
