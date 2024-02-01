import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/bloc/recents/recents_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:meloplay/src/app.dart';
import 'package:meloplay/src/bloc/favorites/favorites_bloc.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/song/song_bloc.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/data/services/hive_box.dart';
import 'package:meloplay/src/service_locator.dart';

Future<void> main() async {
  // initialize flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // initialize dependency injection
  init();

  // set portrait orientation
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

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

  await JustAudioBackground.init(
    androidNotificationChannelName: 'Meloplay Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // run app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<HomeBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<ThemeBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<SongBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<FavoritesBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<PlayerBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<RecentsBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
