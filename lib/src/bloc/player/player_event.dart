part of 'player_bloc.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerInit extends PlayerEvent {}

class PlayerLoadPlaylist extends PlayerEvent {
  final MediaItem mediaItem;
  final List<SongModel> playlist;

  const PlayerLoadPlaylist({required this.mediaItem, required this.playlist});

  @override
  List<Object?> get props => [mediaItem, playlist];
}

class PlayerPlay extends PlayerEvent {}

class PlayerPause extends PlayerEvent {}

class PlayerSeek extends PlayerEvent {
  final Duration position;
  final int? index;

  const PlayerSeek(this.position, {this.index});

  @override
  List<Object?> get props => [position, index];
}

class PlayerNext extends PlayerEvent {}

class PlayerPrevious extends PlayerEvent {}

class PlayerSetShuffle extends PlayerEvent {
  final bool enabled;

  const PlayerSetShuffle(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class PlayerSetLoopMode extends PlayerEvent {
  final LoopMode loopMode;

  const PlayerSetLoopMode(this.loopMode);

  @override
  List<Object?> get props => [loopMode];
}

class PlayerPositionChanged extends PlayerEvent {
  final Duration position;

  const PlayerPositionChanged(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerIndexChanged extends PlayerEvent {
  final int? index;

  const PlayerIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class PlayerPlayingChanged extends PlayerEvent {
  final bool playing;

  const PlayerPlayingChanged(this.playing);

  @override
  List<Object?> get props => [playing];
}

class PlayerRefreshSongs extends PlayerEvent {
  const PlayerRefreshSongs();
}
