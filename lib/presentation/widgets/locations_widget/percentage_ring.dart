import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class PercentageRing extends StatefulWidget {
  final double value;

  const PercentageRing({super.key, required this.value});

  @override
  State<PercentageRing> createState() => _PercentageRingState();
}

class _PercentageRingState extends State<PercentageRing> {
  late ValueNotifier<double> valueNotifier;

  @override
  void initState() {
    super.initState();

    valueNotifier = ValueNotifier(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      child: SimpleCircularProgressBar(
        valueNotifier: valueNotifier,
        progressColors: [
          Color(0xFF9FCA86),
        ],
        onGetText: (double value) {
          return Text(
            '${value.toInt()}%',
            style: TextStyle(
              color: Color(0xFF767676),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        },
        animationDuration: 1,
        backColor: Color(0xFFEBEBEB),
        size: 69,
        backStrokeWidth: 9,
        progressStrokeWidth: 9,
        mergeMode: true,
      ),
    );
  }
}
