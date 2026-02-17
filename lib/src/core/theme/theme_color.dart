import 'package:flutter/material.dart';

abstract class ThemeColor {
  final String name;
  final Color background;
  final Color accent;
  final Brightness brightness;

  const ThemeColor({
    required this.name,
    required this.background,
    required this.accent,
    required this.brightness,
  });

  ColorScheme get colorScheme =>
      ColorScheme.fromSeed(seedColor: accent, brightness: brightness);

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, accent],
  );
}
