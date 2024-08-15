import 'package:flutter/material.dart';
// import '../widgets/gradient.dart';
import '../widgets/appbar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: MediaQuery.sizeOf(context).width*.01,
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
          ),
        ],
      ),
    );


  }
}
