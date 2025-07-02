import 'package:flutter/material.dart';

class MainMenuItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Function action;

  const MainMenuItem({
    super.key,
    required this.label,
    required this.action,
    this.icon = Icons.arrow_right_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Icon(icon, color: Color(0xFFA67F00)),
          SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA67F00),
              fontSize: 18,
            ),
          ),
        ],
      ),
      onTap: () => action(),
    );
  }
}
