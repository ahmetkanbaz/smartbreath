import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColor: Colors.grey.shade900,
    cursorColor: Color(0xFF8983F7),
    canvasColor: Color(0xFFA3DAFB),
    focusColor: Colors.white,
    secondaryHeaderColor: Color(0xFFDBDBDB),
    colorScheme: ColorScheme.dark(),
  );
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade100,
    secondaryHeaderColor: Color(0xFF989899),
    canvasColor: Color(0xDDFF0080),
    focusColor: Colors.black,
    cursorColor: Color(0xDDFF8C00),
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(),
  );
}
