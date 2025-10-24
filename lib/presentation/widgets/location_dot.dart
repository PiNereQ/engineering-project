import 'package:flutter/material.dart';

class LocationDot extends StatelessWidget {
  const LocationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 24,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 89, 180, 255),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF000000),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.5),
            blurRadius: 0,
            offset: Offset(3, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 89, 180, 255),
          shape: BoxShape.circle,
          border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 3),
        ),
      ),
    );
  }
}