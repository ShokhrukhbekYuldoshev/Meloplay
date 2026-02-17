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
            title: const Text('Themes'),
          ),
          body: Ink(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: themeNames.length,
              itemBuilder: (context, index) {
                final themeName = themeNames[index];
                return _buildThemeButton(context, themeName, state.theme);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    String themeName,
    String selectedTheme,
  ) {
    final theme = Themes.themes.firstWhere((t) => t.themeName == themeName);

    final isSelected = selectedTheme == themeName;

    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Stack(
      children: [
        Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: theme.gradient,
            boxShadow: [
              BoxShadow(
                color: theme.secondaryColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: -4,
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.read<ThemeBloc>().add(ChangeTheme(themeName));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  themeName,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        /// Selected Indicator
        if (isSelected)
          Positioned(
            bottom: 8,
            right: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.secondaryColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.secondaryColor.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.check, size: 18, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
