import 'package:flutter/material.dart';

class ProductQuantity extends StatelessWidget {
  final String productName;
  final int quantity;

  const ProductQuantity({
    super.key,
    required this.productName,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: EdgeInsets.fromLTRB(9, 6, 9, 6),
      decoration: BoxDecoration(
        color: Color(0xFFEFE2ED),
        borderRadius: BorderRadius.all(
          Radius.circular(
            15,
          ),
        ),
      ),
      child: Text(
        '$quantity de $productName',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF97133E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
