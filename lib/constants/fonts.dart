import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppFonts {
  // Font for headers
  static const TextStyle header = TextStyle(
    fontFamily: 'SFPRODISPLAY',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Font for sub-headers / sub-content
  static const TextStyle subHeader = TextStyle(
    fontFamily: 'SFPRODISPLAY',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  // Font for content/body
  static const TextStyle body = TextStyle(
    fontFamily: 'SFPRODISPLAY',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  static const TextStyle headerw = TextStyle(
    fontFamily: 'SFPRODISPLAY',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Font for sub-headers / sub-content
  static const TextStyle subHeaderw = TextStyle(
    fontFamily: 'SFPRODISPLAY',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Font for content/body
  static const TextStyle bodyw = TextStyle(
    fontFamily: 'SFPRODISPLAY',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle bodyb = TextStyle(
    fontFamily: 'SFPRODISPLAY',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.primaryBlue,
  );
}
