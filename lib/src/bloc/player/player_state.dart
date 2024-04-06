part of 'player_bloc.dart';

@immutable
sealed class PlayerState {}

final class PlayerInitial extends PlayerState {}

final class PlayerPlaying extends PlayerState {}

final class PlayerPaused extends PlayerState {}

final class PlayerStopped extends PlayerState {}

final class PlayerSongsLoaded extends PlayerState {}

final class PlayerSeeked extends PlayerState {
  final Duration position;

  PlayerSeeked(this.position);
}

final class PlayerError extends PlayerState {
  final String message;

  PlayerError(this.message);
}

final class PlayerLoading extends PlayerState {}

final class PlayerNexted extends PlayerState {}

final class PlayerPrevioussed extends PlayerState {}

final class PlayerShuffled extends PlayerState {}

final class PlayerLooped extends PlayerState {}

final class PlayerVolumeSet extends PlayerState {
  final double volume;

  PlayerVolumeSet(this.volume);
}

final class PlayerSpeedSet extends PlayerState {
  final double speed;

  PlayerSpeedSet(this.speed);
}

final class PlayerLoopModeSet extends PlayerState {
  final LoopMode loopMode;

  PlayerLoopModeSet(this.loopMode);
}

final class PlayerShuffleModeEnabledSet extends PlayerState {
  final bool shuffleModeEnabled;

  PlayerShuffleModeEnabledSet(this.shuffleModeEnabled);
}
