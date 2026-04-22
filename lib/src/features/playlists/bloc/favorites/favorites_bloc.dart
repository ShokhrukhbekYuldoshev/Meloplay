import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/src/features/playlists/data/repositories/song_repository.dart';

import 'package:on_audio_query/on_audio_query.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({required SongRepository repository})
    : super(FavoritesInitial()) {
    on<FetchFavorites>((event, emit) async {
      emit(FavoritesLoading());
      try {
        final favoriteSongs = await repository.getFavoriteSongs();
        emit(FavoritesLoaded(favoriteSongs));
      } catch (e) {
        emit(FavoritesError(e.toString()));
      }
    });
  }
}
