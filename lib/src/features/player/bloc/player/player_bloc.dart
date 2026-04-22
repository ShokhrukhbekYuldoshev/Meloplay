import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/src/core/services/music_player.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final MusicPlayer _player;
  Timer? _sleepTimer;

  StreamSubscription? _positionSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _shuffleSub;
  StreamSubscription? _loopSub;

  PlayerBloc(this._player) : super(const PlayerState()) {
    on<PlayerInit>(_onInit);
    on<PlayerLoadPlaylist>(_onLoadPlaylist);
    on<PlayerPlay>((e, emit) => _player.play());
    on<PlayerPause>((e, emit) => _player.pause());
    on<PlayerSeek>(_onSeek);
    on<PlayerNext>((e, emit) => _player.seekToNext());
    on<PlayerPrevious>((e, emit) => _player.seekToPrevious());
    on<PlayerSetShuffle>(_onSetShuffle);
    on<PlayerSetLoopMode>(_onSetLoopMode);
    on<PlayerPositionChanged>(
      (e, emit) => emit(state.copyWith(position: e.position)),
    );
    on<PlayerIndexChanged>(_onIndexChanged);
    on<PlayerPlayingChanged>(
      (e, emit) => emit(state.copyWith(isPlaying: e.playing)),
    );
    on<StartSleepTimer>(_onStartSleepTimer);
    on<CancelSleepTimer>(_onCancelSleepTimer);
    on<UpdateSleepTimer>(_onUpdateSleepTimer);
  }

  Future<void> _onInit(PlayerInit event, Emitter<PlayerState> emit) async {
    await _player.init();

    _positionSub = _player.position.listen(
      (pos) => add(PlayerPositionChanged(pos)),
    );

    _indexSub = _player.currentIndex.listen((i) => add(PlayerIndexChanged(i)));

    _playingSub = _player.playing.listen((p) => add(PlayerPlayingChanged(p)));

    _durationSub = _player.duration.listen((d) {
      if (d != null) {
        emit(state.copyWith(duration: d));
      }
    });

    _shuffleSub = _player.shuffleModeEnabled.listen(
      (enabled) => emit(state.copyWith(isShuffleEnabled: enabled)),
    );

    _loopSub = _player.loopMode.listen(
      (mode) => emit(state.copyWith(loopMode: mode)),
    );
  }

  Future<void> _onLoadPlaylist(
    PlayerLoadPlaylist event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    await _player.load(event.mediaItem, event.playlist);

    emit(
      state.copyWith(
        playlist: event.playlist,
        currentSong: event.mediaItem,
        currentIndex: event.playlist.indexWhere(
          (s) => s.id.toString() == event.mediaItem.id,
        ),
        isLoading: false,
      ),
    );
  }

  Future<void> _onSeek(PlayerSeek event, Emitter<PlayerState> emit) async {
    await _player.seek(event.position, index: event.index);
  }

  Future<void> _onSetShuffle(
    PlayerSetShuffle event,
    Emitter<PlayerState> emit,
  ) async {
    await _player.setShuffleModeEnabled(event.enabled);
  }

  Future<void> _onSetLoopMode(
    PlayerSetLoopMode event,
    Emitter<PlayerState> emit,
  ) async {
    await _player.setLoopMode(event.loopMode);
  }

  void _onIndexChanged(PlayerIndexChanged event, Emitter<PlayerState> emit) {
    if (event.index == null || state.playlist.isEmpty) return;

    final song = state.playlist[event.index!];

    emit(
      state.copyWith(
        currentIndex: event.index!,
        currentSong: _player.getMediaItemFromSong(song),
      ),
    );
  }

  // sleep timer events
  void _onStartSleepTimer(StartSleepTimer event, Emitter<PlayerState> emit) {
    // Cancel existing timer
    _sleepTimer?.cancel();

    final endTime = DateTime.now().add(event.duration);

    // Update state immediately
    emit(
      state.copyWith(
        sleepTimerRemaining: event.duration,
        isSleepTimerActive: true,
      ),
    );

    // Start periodic timer to update remaining time
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = endTime.difference(DateTime.now());

      if (remaining <= Duration.zero) {
        // Time's up - stop the music
        timer.cancel();
        _sleepTimer = null;
        _player.stop();

        // Update state to inactive
        add(CancelSleepTimer());
      } else {
        // Update remaining time
        add(UpdateSleepTimer(remaining));
      }
    });
  }

  void _onCancelSleepTimer(CancelSleepTimer event, Emitter<PlayerState> emit) {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    emit(state.copyWith(sleepTimerRemaining: null, isSleepTimerActive: false));
  }

  void _onUpdateSleepTimer(UpdateSleepTimer event, Emitter<PlayerState> emit) {
    emit(
      state.copyWith(
        sleepTimerRemaining: event.remaining,
        isSleepTimerActive: true,
      ),
    );

    // Debug
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _indexSub?.cancel();
    _playingSub?.cancel();
    _durationSub?.cancel();
    _shuffleSub?.cancel();
    _loopSub?.cancel();
    _sleepTimer?.cancel();
    return super.close();
  }
}
