import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/presentation/pages/splash_page.dart';
import 'package:meloplay/src/presentation/utils/app_router.dart';
import 'package:meloplay/src/presentation/utils/theme/app_theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Meloplay',
          theme: AppThemeData.getTheme(),
          home: const SplashPage(),
          onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
        );
      },
    );
  }
}
