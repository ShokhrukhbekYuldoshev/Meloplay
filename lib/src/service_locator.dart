import 'package:get_it/get_it.dart';
import 'package:meloplay/src/bloc/favorites/favorites_bloc.dart';
import 'package:meloplay/src/bloc/home/home_bloc.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/data/repositories/favorites_repository.dart';
import 'package:meloplay/src/data/repositories/home_repository.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/data/repositories/song_repository.dart';
import 'package:meloplay/src/data/repositories/theme_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

final sl = GetIt.instance;

void init() {
  // Bloc
  sl.registerFactory(() => FavoritesBloc(repository: sl()));
  sl.registerFactory(() => PlayerBloc(repository: sl()));
  sl.registerFactory(() => HomeBloc(repository: sl()));
  sl.registerFactory(() => ThemeBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => FavoritesRepository());
  sl.registerLazySingleton(() => SongRepository());
  sl.registerLazySingleton(() => ThemeRepository());
  sl.registerLazySingleton(() => PlayerRepository());
  sl.registerLazySingleton(() => HomeRepository());

  // Third Party
  sl.registerLazySingleton(() => OnAudioQuery());
}
