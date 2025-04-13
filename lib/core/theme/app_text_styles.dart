import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
  );

  static TextStyle get displaySmall =>
      GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold);

  static TextStyle get headlineLarge =>
      GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600);

  static TextStyle get headlineMedium =>
      GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get headlineSmall =>
      GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle get titleLarge =>
      GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500);

  static TextStyle get titleMedium =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get titleSmall =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get bodyLarge =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get bodyMedium =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal);

  static TextStyle get bodySmall =>
      GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal);

  static TextStyle get labelLarge =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get labelMedium =>
      GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500);

  static TextStyle get labelSmall =>
      GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500);

  // Temperature styles
  static TextStyle get temperature =>
      GoogleFonts.poppins(fontSize: 64, fontWeight: FontWeight.bold);

  static TextStyle get temperatureFeelsLike =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal);

  // Weather condition style
  static TextStyle get weatherCondition =>
      GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500);

  // City name style
  static TextStyle get cityName => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  // Weather detail style
  static TextStyle get weatherDetail =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);

  // Weather detail value style
  static TextStyle get weatherDetailValue =>
      GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold);

  // Forecast day style
  static TextStyle get forecastDay =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);

  // Forecast temperature style
  static TextStyle get forecastTemperature =>
      GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold);
}
