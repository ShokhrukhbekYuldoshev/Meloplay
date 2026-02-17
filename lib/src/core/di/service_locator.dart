import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/bloc/favorites/favorites_bloc.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/bloc/recents/recents_bloc.dart';
import 'package:meloplay/src/bloc/scan/scan_cubit.dart';
import 'package:meloplay/src/bloc/search/search_bloc.dart';
import 'package:meloplay/src/bloc/song/song_bloc.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';

import 'package:meloplay/src/data/repositories/favorites_repository.dart';
import 'package:meloplay/src/data/repositories/home_repository.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/data/repositories/recents_repository.dart';
import 'package:meloplay/src/data/repositories/search_repository.dart';
import 'package:meloplay/src/data/repositories/song_repository.dart';
import 'package:meloplay/src/data/repositories/theme_repository.dart';

final sl = GetIt.instance;

void init() {
  /// -----------------------
  /// THIRD PARTY
  /// -----------------------

  // Single AudioPlayer instance (VERY IMPORTANT)
  sl.registerLazySingleton<AudioPlayer>(() => AudioPlayer());

  sl.registerLazySingleton(() => OnAudioQuery());

  /// -----------------------
  /// REPOSITORIES
  /// -----------------------

  sl.registerLazySingleton(() => ThemeRepository());
  sl.registerLazySingleton(() => HomeRepository());
  sl.registerLazySingleton(() => SongRepository());
  sl.registerLazySingleton(() => FavoritesRepository());
  sl.registerLazySingleton(() => RecentsRepository());
  sl.registerLazySingleton(() => SearchRepository());

  // MusicPlayer abstraction using SAME AudioPlayer
  sl.registerLazySingleton<MusicPlayer>(() => JustAudioPlayer());

  /// -----------------------
  /// BLOCS
  /// -----------------------

  sl.registerFactory(() => ThemeBloc());

  sl.registerFactory(() => HomeBloc(repository: sl<HomeRepository>()));

  sl.registerFactory(() => PlayerBloc(sl<MusicPlayer>()));

  sl.registerFactory(() => SongBloc(repository: sl<SongRepository>()));

  sl.registerFactory(
    () => FavoritesBloc(repository: sl<FavoritesRepository>()),
  );

  sl.registerFactory(() => RecentsBloc(repository: sl<RecentsRepository>()));

  sl.registerFactory(() => SearchBloc(repository: sl<SearchRepository>()));

  /// -----------------------
  /// CUBITS
  /// -----------------------

  sl.registerFactory(() => ScanCubit());
  sl.registerFactory(() => PlaylistsCubit());
}
