import 'package:flutter/material.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';

class AppThemeData {
  static ThemeData getTheme() {
    final theme = Themes.getTheme();
    return ThemeData(
      colorScheme: theme.colorScheme,
      useMaterial3: true,
      sliderTheme: SliderThemeData(
        trackHeight: 2.0,
        inactiveTrackColor: theme.primaryColor.withOpacity(0.3),
        overlayColor: theme.primaryColor.withOpacity(0.3),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 6.0,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 12.0,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: theme.primaryColor,
      ),
    );
  }
}
