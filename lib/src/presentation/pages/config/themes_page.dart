import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Themes.getTheme().secondaryColor,
          appBar: AppBar(
            backgroundColor: Themes.getTheme().primaryColor,
            elevation: 0,
            title: const Text('Themes'),
            centerTitle: false,
          ),
          body: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(gradient: Themes.getTheme().gradient),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: themeNames.length,
              itemBuilder: (context, index) {
                final themeName = themeNames[index];
                return _buildThemeCard(context, themeName, state.theme);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    String themeName,
    String selectedTheme,
  ) {
    final theme = Themes.themes.firstWhere((t) => t.themeName == themeName);
    final isSelected = selectedTheme == themeName;
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: theme.gradient,
        boxShadow: [
          BoxShadow(
            color: theme.secondaryColor.withValues(alpha: 0.3),
            blurRadius: isSelected ? 16 : 8,
            spreadRadius: isSelected ? 0 : -2,
            offset: const Offset(0, 4),
          ),
        ],
        border: isSelected
            ? Border.all(color: theme.secondaryColor, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<ThemeBloc>().add(ChangeTheme(themeName));
            Fluttertoast.showToast(
              msg: 'Theme changed to $themeName',
              backgroundColor: theme.secondaryColor,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
          },
          child: Stack(
            children: [
              // Theme Preview Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Preview circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.palette,
                      color: isDark ? Colors.white : Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Theme name
                  Text(
                    themeName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Preview colors
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Selected Indicator
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.secondaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: theme.secondaryColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
