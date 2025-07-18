import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final Widget child;
  final String title;

  const HomeCard({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
      elevation: 0.3,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF97133E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            padding: EdgeInsets.all(9),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 21,
                  color: Color(0xFFEEE6CD),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: child,
          )
        ],
      ),
    );
  }
}
