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
  ];
}
