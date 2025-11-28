import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Nueva paleta de colores verde suave y profesional
const Color mint = Color(0xFFE2F7EF); // fondo principal
const Color lightGreen = Color(0xFFA7E1C2); // tarjetas, contenedores
const Color softGreen = Color(0xFF5DB075); // inputs, acentos
const Color darkGreen = Color(0xFF234F32); // textos, encabezados
const Color white = Color(0xFFFFFFFF); // botones y fondos claros

// Mantener compatibilidad con código existente
const Color vetproGreen = softGreen;

final ThemeData appTheme = ThemeData(
  primaryColor: softGreen,
  colorScheme: ColorScheme.fromSeed(seedColor: softGreen),
  scaffoldBackgroundColor: mint,
  textTheme: GoogleFonts.kodchasanTextTheme(),
  appBarTheme: const AppBarTheme(
    backgroundColor: softGreen,
    foregroundColor: white,
    elevation: 0),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: white,
      foregroundColor: darkGreen)));
