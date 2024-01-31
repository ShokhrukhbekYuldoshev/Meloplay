part of 'player_bloc.dart';

@immutable
sealed class PlayerEvent {}

// toggle favorite
class ToggleFavorite extends PlayerEvent {
  final String songId;

  ToggleFavorite(this.songId);
}

// add to recently played
class AddToRecentlyPlayed extends PlayerEvent {
  final String songId;

  AddToRecentlyPlayed(this.songId);
}
