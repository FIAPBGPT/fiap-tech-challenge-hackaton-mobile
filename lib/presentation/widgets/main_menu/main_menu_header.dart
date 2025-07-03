import 'package:flutter/material.dart';

class MainMenuHeader extends StatelessWidget {
  final String userName;

  const MainMenuHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Color(0xFF59734A)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.person_outlined,
            size: 60,
            color: Colors.white,
          ),
          Text(
            userName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          Text(
            'Analista Administrativo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Jura',
              ),
              children: [
                TextSpan(
                  text: 'Matrícula ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: '123456',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
