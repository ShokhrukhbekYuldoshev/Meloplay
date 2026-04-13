import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/src/data/services/music_player.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final MusicPlayer _player;

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

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _indexSub?.cancel();
    _playingSub?.cancel();
    _durationSub?.cancel();
    _shuffleSub?.cancel();
    _loopSub?.cancel();
    return super.close();
  }
}
