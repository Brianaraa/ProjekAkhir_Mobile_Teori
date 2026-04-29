import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData
   lightTheme = ThemeData(
    fontFamily: 'NotoSerif-Regular',
    primaryColor: Colors.black,

    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black
      ),

      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black
      ),

      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.grey
      )
    ),

    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),

  );
}