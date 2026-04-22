import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/features/playlists/bloc/playlists/playlists_cubit.dart';
import 'package:meloplay/src/features/playlists/bloc/favorites/favorites_bloc.dart';
import 'package:meloplay/src/features/home/bloc/home/home_bloc.dart';
import 'package:meloplay/src/features/player/bloc/player/player_bloc.dart';
import 'package:meloplay/src/features/playlists/bloc/recents/recents_bloc.dart';
import 'package:meloplay/src/features/config/bloc/scan/scan_cubit.dart';
import 'package:meloplay/src/features/home/bloc/search/search_bloc.dart';
import 'package:meloplay/src/features/player/bloc/song/song_bloc.dart';
import 'package:meloplay/src/features/config/bloc/theme/theme_bloc.dart';

import 'package:meloplay/src/features/home/data/repositories/home_repository.dart';
import 'package:meloplay/src/core/services/music_player.dart';
import 'package:meloplay/src/features/home/data/repositories/search_repository.dart';
import 'package:meloplay/src/features/playlists/data/repositories/song_repository.dart';

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

  sl.registerLazySingleton(() => HomeRepository());
  sl.registerLazySingleton(() => SongRepository());
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

  sl.registerFactory(() => FavoritesBloc(repository: sl<SongRepository>()));

  sl.registerFactory(() => RecentsBloc(repository: sl<SongRepository>()));

  sl.registerFactory(() => SearchBloc(repository: sl<SearchRepository>()));

  /// -----------------------
  /// CUBITS
  /// -----------------------

  sl.registerFactory(() => ScanCubit());
  sl.registerFactory(() => PlaylistsCubit());
}
