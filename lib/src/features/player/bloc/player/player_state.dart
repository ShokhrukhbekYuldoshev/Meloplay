part of 'player_bloc.dart';

class PlayerState extends Equatable {
  final List<SongModel> playlist;
  final MediaItem? currentSong;
  final int currentIndex;
  final bool isPlaying;
  final bool isShuffleEnabled;
  final LoopMode loopMode;
  final Duration position;
  final Duration duration;
  final bool isLoading;

  // sleep timer fields
  final Duration? sleepTimerRemaining;
  final bool isSleepTimerActive;

  const PlayerState({
    this.playlist = const [],
    this.currentSong,
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isShuffleEnabled = false,
    this.loopMode = LoopMode.off,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isLoading = false,

    // sleep timer defaults
    this.sleepTimerRemaining,
    this.isSleepTimerActive = false,
  });

  PlayerState copyWith({
    List<SongModel>? playlist,
    MediaItem? currentSong,
    int? currentIndex,
    bool? isPlaying,
    bool? isShuffleEnabled,
    LoopMode? loopMode,
    Duration? position,
    Duration? duration,
    bool? isLoading,
    Duration? sleepTimerRemaining,
    bool? isSleepTimerActive,
  }) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      currentSong: currentSong ?? this.currentSong,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      loopMode: loopMode ?? this.loopMode,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
      sleepTimerRemaining: sleepTimerRemaining ?? this.sleepTimerRemaining,
      isSleepTimerActive: isSleepTimerActive ?? this.isSleepTimerActive,
    );
  }

  @override
  List<Object?> get props => [
    playlist,
    currentSong,
    currentIndex,
    isPlaying,
    isShuffleEnabled,
    loopMode,
    position,
    duration,
    isLoading,
    sleepTimerRemaining,
    isSleepTimerActive,
  ];
}
