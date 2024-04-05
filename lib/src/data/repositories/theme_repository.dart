import 'package:meloplay/src/core/theme/themes.dart';

class ThemeRepository {
  Future<void> updateTheme(String themeName) async {
    await Themes.setTheme(themeName);
  }
}
