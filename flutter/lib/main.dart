import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme.dart';
import 'pages/home.dart'; 
import 'pages/analyst.dart'; 
import 'pages/steward.dart'; 
import 'pages/admin.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Flask Integration',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomePage(title: 'Flutter Flask Integration Home Page'),
            '/analyst': (context) => const AnalystPage(title: 'Analyst page'),
            '/steward': (context) => const StewardPage(title: 'Steward page'),
            '/admin': (context) => const AdminPage(title: 'Admin page'),
          },
        );
      },
    );
  }
}

