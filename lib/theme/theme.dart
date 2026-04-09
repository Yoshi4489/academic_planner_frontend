import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Color.fromRGBO(31, 93, 252, 1),
    secondary: Colors.grey.shade200
  ),
  textTheme: TextTheme(
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 14, color: Colors.grey.shade800),
    labelMedium: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
    labelSmall: TextStyle(fontSize: 16, color: Colors.white),
    titleMedium: TextStyle(fontSize: 24, color: Color.fromRGBO(0, 0, 0, 0.6)),
    bodyMedium: TextStyle(fontSize: 20, color: Colors.black),
    bodySmall: TextStyle(fontSize: 16, color: Colors.black),
  ),
  fontFamily: GoogleFonts.inika().fontFamily
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Color.fromRGBO(31, 93, 252, 100),
    secondary: Colors.grey.shade700
  ),
    textTheme: TextTheme(
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        labelMedium: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        labelSmall: TextStyle(fontSize: 16, color: Colors.white),
        titleMedium: TextStyle(fontSize: 24, color: Color.fromRGBO(0, 0, 0, 0.6)),
        bodySmall: TextStyle(fontSize: 16, color: Colors.white)
    ),
  fontFamily: GoogleFonts.inika().fontFamily
);