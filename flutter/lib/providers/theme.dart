import 'package:flutter/material.dart';

const Color offWhite = Color.fromARGB(255, 204, 204, 204);
const Color offBlack = Color.fromARGB(255, 55, 55, 55);
const Color offBlack1 = Color.fromARGB(255, 55, 55, 55);
const Color lightButton = Color.fromARGB(255, 207, 216, 220);
const Color darkButton = Color.fromARGB(255, 79, 79, 79);
const Color darkButtonText = Color.fromARGB(255, 214, 214, 214);
const Color lightSnackbar = Color.fromARGB(255, 18, 195, 244);
const Color darkSnackbar = Color.fromARGB(255, 19, 129, 190);
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeData lightTheme = ThemeData(
    fontFamily: 'Avenir',
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light, 
      primary: Color.fromRGBO(96, 125, 139, 1),
      surface: Colors.white,
    ),
    useMaterial3: true,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: lightSnackbar,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightButton,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      fillColor: Colors.white,
      hoverColor: Colors.grey[100],
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      labelStyle: const TextStyle(color: Colors.black87),
    )

  );

  ThemeData darkTheme = ThemeData(
    fontFamily: 'Avenir',
    colorScheme:  const ColorScheme.dark(
      primary: Colors.blueGrey,
      surface: offBlack,
    ),
    useMaterial3: true,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkSnackbar,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: offBlack,
      foregroundColor: offWhite,
    ),
    scaffoldBackgroundColor: offBlack,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkButton,
        foregroundColor: darkButtonText,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16.0, color: offWhite),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      fillColor: Color.fromARGB(255, 62, 62, 62),
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      labelStyle: TextStyle(color: Color.fromARGB(255, 236, 235, 228)),
    ),
  );


  ThemeMode get themeMode => _themeMode;
  ThemeData getTheme() {
    return _themeMode == ThemeMode.dark ? darkTheme : lightTheme;
  }
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
