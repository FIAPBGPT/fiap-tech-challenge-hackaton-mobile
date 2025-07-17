import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class GoalBar extends StatelessWidget {
  final double goalValue;
  final double actualValue;

  GoalBar({
    super.key,
    required this.goalValue,
    required this.actualValue,
  });

  final TextStyle textStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final numberFormatter = NumberFormat.decimalPatternDigits(locale: 'pt-BR');

  int _percentage() {
    if (actualValue >= goalValue) return 100;

    return ((actualValue / goalValue) * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '0',
                style: textStyle,
              ),
            ),
            Text(
              "${numberFormatter.format(actualValue)} / ${numberFormatter.format(goalValue)}",
              style: textStyle,
            ),
          ],
        ),

        // The bar
        StepProgressIndicator(
          totalSteps: 100,
          currentStep: _percentage(),
          size: 36,
          padding: 0,
          selectedColor: Color(0xFF97133E),
          unselectedColor: Color(0xFFC9BCC7),
          roundedEdges: Radius.circular(0),
        ),
      ],
    );
  }
}
