import 'package:flutter/material.dart';

class AppBackgroundTheme extends ThemeExtension<AppBackgroundTheme> {
  final String? backgroundImage;

  const AppBackgroundTheme({this.backgroundImage});

  @override
  AppBackgroundTheme copyWith({String? backgroundImage}) {
    return AppBackgroundTheme(
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }

  @override
  AppBackgroundTheme lerp(ThemeExtension<AppBackgroundTheme>? other, double t) {
    if (other is! AppBackgroundTheme) return this;
    return AppBackgroundTheme(
      backgroundImage: t < 0.5 ? backgroundImage : other.backgroundImage,
    );
  }
}
