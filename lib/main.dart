import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:meloplay/data/services/my_audio_handler.dart';
import 'package:meloplay/bloc/home/home_bloc.dart';
import 'package:meloplay/bloc/theme/theme_bloc.dart';
import 'package:meloplay/data/repositories/song_repository.dart';
import 'package:meloplay/data/services/hive_box.dart';
import 'package:meloplay/presentation/pages/splash_page.dart';
import 'package:meloplay/presentation/utils/app_router.dart';
import 'package:meloplay/presentation/utils/theme/app_theme_data.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  // initialize flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // ask for permission to access media if not granted
  if (!await Permission.mediaLibrary.isGranted) {
    await Permission.mediaLibrary.request();
  }

  // ask for notification permission if not granted
  if (!await Permission.notification.isGranted) {
    await Permission.notification.request();
  }

  // initialize hive
  await Hive.initFlutter();
  await Hive.openBox(HiveBox.boxName);

  // initialize audio service

  AudioHandler audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.shokhrukhbek.meloplay.audio',
      androidNotificationChannelName: 'Meloplay Audio',
      androidNotificationChannelDescription: 'Meloplay Audio Service',
    ),
  );

  // run app
  runApp(
    RepositoryProvider(
      create: (context) => SongRepository(
        audioHandler: audioHandler,
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
          BlocProvider(
            create: (context) => HomeBloc(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

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
