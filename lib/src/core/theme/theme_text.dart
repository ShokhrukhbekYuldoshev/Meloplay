// lib/src/core/theme/theme_text.dart
import 'package:flutter/material.dart';
import 'package:meloplay/src/core/theme/themes.dart';

class ThemeText {
  // Get the appropriate text color based on theme brightness
  static Color getPrimaryColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  static Color getSecondaryColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black87.withValues(alpha: 0.7);
  }

  static Color getHintColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black87.withValues(alpha: 0.5);
  }

  static Color getDisabledColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black87.withValues(alpha: 0.3);
  }

  // Getter for current theme's text color
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
  }
}
