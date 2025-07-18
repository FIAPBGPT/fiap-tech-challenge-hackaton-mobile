import 'package:fiap_farms_app/presentation/widgets/locations_widget/percentage_ring.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        const SizedBox(height: 3),
        Text(
          state,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF97133E),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          Intl.plural(
            farmsNumber,
            one: '1 Fazenda',
            other: '$farmsNumber Fazendas',
          ),
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
