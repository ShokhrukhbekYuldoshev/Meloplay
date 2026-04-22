// song_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/src/features/playlists/data/repositories/song_repository.dart';

part 'song_event.dart';
part 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final SongRepository _repository;

  SongBloc({required SongRepository repository})
    : _repository = repository,
      super(PlayerInitial()) {
    on<ToggleFavorite>(_onToggleFavorite);
    on<AddToRecentlyPlayed>(_onAddToRecentlyPlayed);
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<SongState> emit,
  ) async {
    emit(ToggleFavoriteInProgress());
    try {
      await _repository.toggleFavorite(event.songId);
      emit(ToggleFavoriteSuccess());
    } catch (e) {
      emit(ToggleFavoriteFailure());
    }
  }

  Future<void> _onAddToRecentlyPlayed(
    AddToRecentlyPlayed event,
    Emitter<SongState> emit,
  ) async {
    emit(AddToRecentlyPlayedInProgress());
    try {
      await _repository.addToRecentlyPlayed(event.songId);
      emit(AddToRecentlyPlayedSuccess());
    } catch (e) {
      emit(AddToRecentlyPlayedError());
    }
  }
}
