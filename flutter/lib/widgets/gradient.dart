import 'package:flutter/material.dart';

class GradientLine extends StatelessWidget {
  const GradientLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.005,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF12C3F4),
              Color(0xFF6081C1),
              Color(0xFF7456A4),
              Color(0xFFEE312F),
              Color(0xFFF4763C),
              Color(0xFFFAA629),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
    );
  }
}
