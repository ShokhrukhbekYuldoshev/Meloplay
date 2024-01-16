import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/src/app.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/data/repositories/song_repository.dart';
import 'package:meloplay/src/data/services/hive_box.dart';

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

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.shokhrukhbek.meloplay.channel.audio',
    androidNotificationChannelName: 'Meloplay Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // run app
  runApp(
    RepositoryProvider(
      create: (context) => SongRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(),
          ),
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
