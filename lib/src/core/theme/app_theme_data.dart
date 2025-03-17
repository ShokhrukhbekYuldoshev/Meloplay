import 'package:flutter/material.dart';
import 'package:meloplay/src/core/theme/themes.dart';

class AppThemeData {
  static ThemeData getTheme() {
    final theme = Themes.getTheme();
    return ThemeData(
      colorScheme: theme.colorScheme,
      useMaterial3: true,
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder:
            (context) => const Icon(Icons.arrow_back_ios, size: 20),
      ),
      tabBarTheme: TabBarTheme(
        dividerHeight: 0,
        labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.grey,
        thumbColor: Colors.white,
        trackHeight: 2.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: theme.primaryColor),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: theme.primaryColor,
      ),
      dialogTheme: DialogThemeData(backgroundColor: theme.primaryColor),
    );
  }
}
