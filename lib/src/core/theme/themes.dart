import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:meloplay/src/data/services/hive_box.dart';

class Themes {
  static final List<ThemeColor> _themes = [
    PurpleTheme(),
    BlueTheme(),
    GreenTheme(),
    OrangeTheme(),
    YellowTheme(),
    TealTheme(),
    RedTheme(),
    BlackTheme(),
    WhiteTheme(),
  ];

  static final List<String> _themeNames = [
    'Purple',
    'Blue',
    'Green',
    'Orange',
    'Yellow',
    'Teal',
    'Red',
    'Black',
    'White',
  ];

  static get themes => _themes;
  static List<String> get themeNames => _themeNames;

  static ThemeColor getThemeFromKey(String key) {
    switch (key) {
      case 'Purple':
        return _themes[0];
      case 'Blue':
        return _themes[1];
      case 'Green':
        return _themes[2];
      case 'Orange':
        return _themes[3];
      case 'Yellow':
        return _themes[4];
      case 'Teal':
        return _themes[5];
      case 'Red':
        return _themes[6];
      case 'Black':
        return _themes[7];
      case 'White':
        return _themes[8];
      default:
        return _themes[0];
    }
  }

  static Future<void> setTheme(String themeName) async {
    final Box<dynamic> box = Hive.box(HiveBox.boxName);
    await box.put(HiveBox.themeKey, themeName);
  }

  static String getThemeName() {
    final Box<dynamic> box = Hive.box(HiveBox.boxName);
    final String? themeName = box.get(HiveBox.themeKey) as String?;
    return themeName ?? 'Purple';
  }

  static ThemeColor getTheme() {
    final Box<dynamic> box = Hive.box(HiveBox.boxName);
    final String? themeName = box.get(HiveBox.themeKey) as String?;
    return getThemeFromKey(themeName ?? 'Purple');
  }
}

abstract class ThemeColor {
  final String themeName;
  final Color primaryColor;
  final Color secondaryColor;
  final ColorScheme colorScheme;
  final LinearGradient linearGradient;

  const ThemeColor({
    required this.themeName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.colorScheme,
    required this.linearGradient,
  });
}

class PurpleTheme extends ThemeColor {
  PurpleTheme()
      : super(
          themeName: 'Purple',
          primaryColor: const Color(0xff21143d),
          secondaryColor: const Color(0xff47210c),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.purple,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff21143d),
              Color(0xff47210c),
            ],
          ),
        );
}

class BlueTheme extends ThemeColor {
  BlueTheme()
      : super(
          themeName: 'Blue',
          primaryColor: const Color(0xff0c1a47),
          secondaryColor: const Color(0xFF16488A),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff0c1a47),
              Color(0xFF16488A),
            ],
          ),
        );
}

class GreenTheme extends ThemeColor {
  GreenTheme()
      : super(
          themeName: 'Green',
          primaryColor: const Color(0xff0c471a),
          secondaryColor: const Color(0xFF168A48),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff0c471a),
              Color(0xFF168A48),
            ],
          ),
        );
}

class OrangeTheme extends ThemeColor {
  OrangeTheme()
      : super(
          themeName: 'Orange',
          primaryColor: const Color(0xff471a0c),
          secondaryColor: const Color(0xFF8A4816),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff471a0c),
              Color(0xFF8A4816),
            ],
          ),
        );
}

class YellowTheme extends ThemeColor {
  YellowTheme()
      : super(
          themeName: 'Yellow',
          primaryColor: const Color(0xff47410c),
          secondaryColor: const Color(0xFF8A7A16),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.yellow,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff47410c),
              Color(0xFF8A7A16),
            ],
          ),
        );
}

class TealTheme extends ThemeColor {
  TealTheme()
      : super(
          themeName: 'Teal',
          primaryColor: const Color(0xff0c4741),
          secondaryColor: const Color(0xFF168A7A),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.teal,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff0c4741),
              Color(0xFF168A7A),
            ],
          ),
        );
}

class RedTheme extends ThemeColor {
  RedTheme()
      : super(
          themeName: 'Red',
          primaryColor: const Color(0xff470c1a),
          secondaryColor: const Color(0xFF8A1648),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff470c1a),
              Color(0xFF8A1648),
            ],
          ),
        );
}

class BlackTheme extends ThemeColor {
  BlackTheme()
      : super(
          themeName: 'Black',
          primaryColor: const Color(0xff000000),
          secondaryColor: const Color(0xFF1B1B1B),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
            brightness: Brightness.dark,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff000000),
              Color(0xFF1B1B1B),
            ],
          ),
        );
}

class WhiteTheme extends ThemeColor {
  WhiteTheme()
      : super(
          themeName: 'White',
          primaryColor: const Color(0XFFFFFFFF),
          secondaryColor: const Color(0xFFC7C7C7),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
            brightness: Brightness.light,
          ),
          linearGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0XFFFFFFFF),
              Color(0xFFC7C7C7),
            ],
          ),
        );
}
