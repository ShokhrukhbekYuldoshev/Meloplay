import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:meloplay/src/data/services/hive_box.dart';

class Themes {
  static final Map<String, ThemeColor> _themes = {
    PurpleTheme.name: PurpleTheme(),
    BlueTheme.name: BlueTheme(),
    GreenTheme.name: GreenTheme(),
    OrangeTheme.name: OrangeTheme(),
    YellowTheme.name: YellowTheme(),
    TealTheme.name: TealTheme(),
    CyanTheme.name: CyanTheme(),
    LimeTheme.name: LimeTheme(),
    PinkTheme.name: PinkTheme(),
    RedTheme.name: RedTheme(),
    BlackTheme.name: BlackTheme(),
    WhiteTheme.name: WhiteTheme(),
    GrayTheme.name: GrayTheme(),
  };

  static Box<dynamic> get _box => Hive.box(HiveBox.boxName);

  static List<ThemeColor> get themes => _themes.values.toList();
  static List<String> get themeNames => _themes.keys.toList();

  static ThemeColor getTheme() {
    final name = _box.get(HiveBox.themeKey, defaultValue: PurpleTheme.name);
    return _themes[name] ?? PurpleTheme();
  }

  static Future<void> setTheme(String themeName) async {
    await _box.put(HiveBox.themeKey, themeName);
  }

  static String getThemeName() {
    return _box.get(HiveBox.themeKey, defaultValue: PurpleTheme.name);
  }
}

abstract class ThemeColor {
  final String themeName;
  final Color primaryColor;
  final Color secondaryColor;

  const ThemeColor({
    required this.themeName,
    required this.primaryColor,
    required this.secondaryColor,
  });

  ColorScheme get colorScheme =>
      ColorScheme.fromSeed(seedColor: secondaryColor, brightness: brightness);

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, secondaryColor],
  );

  Brightness get brightness;
}

class PurpleTheme extends ThemeColor {
  static const String name = 'Purple';

  PurpleTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF0F0C29),
        secondaryColor: const Color(0xFF6A11CB),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class BlueTheme extends ThemeColor {
  static const String name = 'Blue';

  BlueTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF0F2027),
        secondaryColor: const Color(0xFF00C6FF),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class GreenTheme extends ThemeColor {
  static const String name = 'Green';

  GreenTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF0F2027),
        secondaryColor: const Color(0xFF1DB954),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class OrangeTheme extends ThemeColor {
  static const String name = 'Orange';

  OrangeTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF1A1A1A),
        secondaryColor: const Color(0xFFFF8C42),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class YellowTheme extends ThemeColor {
  static const String name = 'Yellow';

  YellowTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF1C1C1C),
        secondaryColor: const Color(0xFFFFC107),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class TealTheme extends ThemeColor {
  static const String name = 'Teal';

  TealTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF0F2027),
        secondaryColor: const Color(0xFF00BFA6),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class CyanTheme extends ThemeColor {
  static const String name = 'Cyan';

  CyanTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF0F2027),
        secondaryColor: const Color(0xFF00FFFF),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class LimeTheme extends ThemeColor {
  static const String name = 'Lime';

  LimeTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF1C1C1C),
        secondaryColor: const Color(0xFFCDDC39),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class PinkTheme extends ThemeColor {
  static const String name = 'Pink';

  PinkTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF1C1C1C),
        secondaryColor: const Color(0xFFFF4081),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class RedTheme extends ThemeColor {
  static const String name = 'Red';

  RedTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF1A0000),
        secondaryColor: const Color(0xFFE10600),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class BlackTheme extends ThemeColor {
  static const String name = 'Black';

  BlackTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF000000),
        secondaryColor: const Color(0xFF121212),
      );

  @override
  Brightness get brightness => Brightness.dark;
}

class WhiteTheme extends ThemeColor {
  static const String name = 'White';

  WhiteTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFFF5F7FA),
        secondaryColor: const Color(0xFFE4E7EB),
      );

  @override
  Brightness get brightness => Brightness.light;
}

class GrayTheme extends ThemeColor {
  static const String name = 'Gray';

  GrayTheme()
    : super(
        themeName: name,
        primaryColor: const Color(0xFF232526),
        secondaryColor: const Color(0xFF414345),
      );

  @override
  Brightness get brightness => Brightness.dark;
}
