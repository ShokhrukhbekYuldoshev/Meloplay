import 'package:flutter/material.dart';
import 'package:meloplay/src/core/theme/themes.dart';

class ThemeColors {
  static Color surfaceColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.03);
  }

  static Color surfaceHoverColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.06);
  }

  // Border colors
  static Color borderColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
  }

  // Divider color
  static Color dividerColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
  }

  // Icon colors
  static Color iconColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black87.withValues(alpha: 0.6);
  }

  // Shadow color
  static Color shadowColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);
  }

  // Overlay color (now playing highlight)
  static Color overlayColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
  }

  static Color textColor(BuildContext context) {
    final theme = Themes.getTheme();
    return theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.87)
        : Colors.black87;
  }
}
