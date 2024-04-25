import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/core/theme/themes.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  final themeNames = Themes.themeNames;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Themes.getTheme().secondaryColor,
          appBar: AppBar(
            backgroundColor: Themes.getTheme().primaryColor,
            elevation: 0,
            title: const Text(
              'Themes',
            ),
          ),
          body: Ink(
            padding: const EdgeInsets.fromLTRB(
              32,
              16,
              32,
              16,
            ),
            decoration: BoxDecoration(
              gradient: Themes.getTheme().linearGradient,
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: themeNames.length,
              itemBuilder: (context, index) {
                final themeName = themeNames[index];
                return _buildThemeButton(themeName);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeButton(String themeName) {
    return Stack(
      children: [
        Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: Themes.getThemeFromKey(themeName).linearGradient,
            boxShadow: [
              BoxShadow(
                color: Themes.getThemeFromKey(themeName)
                    .colorScheme
                    .primary
                    .withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: -5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.read<ThemeBloc>().add(
                    ChangeTheme(themeName),
                  );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  themeName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Themes.getThemeFromKey(
                              themeName,
                            ).colorScheme.brightness ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (Themes.getThemeName() == themeName)
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
