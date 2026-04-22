// favorites_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/src/features/playlists/data/repositories/song_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final SongRepository _repository;

  FavoritesBloc({required SongRepository repository})
    : _repository = repository,
      super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
  }

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favoriteSongs = await _repository.getFavoriteSongs();
      emit(FavoritesLoaded(favoriteSongs));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
