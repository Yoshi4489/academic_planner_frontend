import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade400,
    primary: Colors.grey.shade300,
    secondary: Colors.grey.shade200
  ),
  textTheme: TextTheme(
    titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(fontSize: 14, color: Colors.grey.shade800)
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700
  ),
    textTheme: TextTheme(
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        titleSmall: TextStyle(fontSize: 14, color: Colors.grey.shade400)
    )
);