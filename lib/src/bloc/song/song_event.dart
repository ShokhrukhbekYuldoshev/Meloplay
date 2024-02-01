part of 'song_bloc.dart';

@immutable
sealed class SongEvent {}

// toggle favorite
class ToggleFavorite extends SongEvent {
  final String songId;

  ToggleFavorite(this.songId);
}

// add to recently played
class AddToRecentlyPlayed extends SongEvent {
  final String songId;

  AddToRecentlyPlayed(this.songId);
}
