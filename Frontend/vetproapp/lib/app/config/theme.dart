import 'package:flutter/material.dart';

const Color vetproGreen = Color(0xFF15803D);

final ThemeData appTheme = ThemeData(
  primaryColor: vetproGreen,
  colorScheme: ColorScheme.fromSeed(seedColor: vetproGreen),
  scaffoldBackgroundColor: vetproGreen,
  appBarTheme: const AppBarTheme(
    backgroundColor: vetproGreen,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: vetproGreen,
    ),
  ),
);
