import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/bloc/theme/theme_bloc.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
              ),
            ),
            title: const Text(
              'Settings',
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Themes',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // theme options
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: themeNames
                        .map(
                          (themeName) => Ink(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: Themes.getThemeFromKey(themeName)
                                  .linearGradient,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Stack(
                                  children: [
                                    Align(
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
                                    if (Themes.getThemeName() == themeName)
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.check,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
