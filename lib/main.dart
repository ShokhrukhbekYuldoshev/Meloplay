import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:meloplay/src/app.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/services/hive_box.dart';
import 'package:meloplay/src/core/services/music_player.dart';
import 'package:meloplay/src/core/services/playlist_db.dart';
import 'package:meloplay/src/features/config/bloc/scan/scan_cubit.dart';
import 'package:meloplay/src/features/config/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/features/home/bloc/home/home_bloc.dart';
import 'package:meloplay/src/features/home/bloc/search/search_bloc.dart';
import 'package:meloplay/src/features/player/bloc/player/player_bloc.dart';
import 'package:meloplay/src/features/playlists/bloc/favorites/favorites_bloc.dart';
import 'package:meloplay/src/features/playlists/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/features/playlists/bloc/recents/recents_bloc.dart';
import 'package:meloplay/src/features/playlists/bloc/song/song_bloc.dart';

Future<void> main() async {
  // initialize flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Playlist DB Service first
  await PlaylistDB().init();

  // initialize dependency injection
  init();

  // ask for permission to access media if not granted
  if (!await Permission.mediaLibrary.isGranted) {
    await Permission.mediaLibrary.request();
  }

  // initialize hive
  await Hive.initFlutter();
  await Hive.openBox(HiveBox.boxName);

  // initialize audio service
  await sl<MusicPlayer>().init();

  // run app
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<HomeBloc>()),
        BlocProvider(create: (context) => sl<ThemeBloc>()),
        BlocProvider(create: (context) => sl<SongBloc>()),
        BlocProvider(create: (context) => sl<FavoritesBloc>()),
        BlocProvider(create: (context) => sl<PlayerBloc>()),
        BlocProvider(create: (context) => sl<RecentsBloc>()),
        BlocProvider(create: (context) => sl<SearchBloc>()),
        BlocProvider(create: (context) => sl<ScanCubit>()),
        BlocProvider(create: (context) => sl<PlaylistsCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
