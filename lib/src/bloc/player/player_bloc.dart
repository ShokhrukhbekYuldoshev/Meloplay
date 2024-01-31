import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required PlayerRepository repository}) : super(PlayerInitial()) {
    on<ToggleFavorite>((event, emit) async {
      emit(ToggleFavoriteInProgress());
      try {
        await repository.toggleFavorite(event.songId);
        emit(ToggleFavoriteSuccess());
      } catch (e) {
        emit(ToggleFavoriteFailure());
      }
    });
    on<AddToRecentlyPlayed>((event, emit) async {
      emit(AddToRecentlyPlayedInProgress());
      try {
        await repository.addToRecentlyPlayed(event.songId);
        emit(AddToRecentlyPlayedSuccess());
      } catch (e) {
        emit(AddToRecentlyPlayedError());
      }
    });
  }
}
