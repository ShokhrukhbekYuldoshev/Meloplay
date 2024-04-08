import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/data/repositories/player_repository.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({required JustAudioPlayer repository}) : super(PlayerInitial()) {
    on<PlayerLoadSongs>((event, emit) async {
      try {
        emit(PlayerLoading());
        await repository.load(event.mediaItem, event.playlist);
        emit(PlayerSongsLoaded());
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });
    on<PlayerPlay>((event, emit) async {
      try {
        await repository.play();
        emit(PlayerPlaying());
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerPause>((event, emit) async {
      try {
        await repository.pause();
        emit(PlayerPaused());
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerStop>((event, emit) async {
      try {
        await repository.stop();
        emit(PlayerStopped());
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerSeek>((event, emit) async {
      try {
        await repository.seek(event.position, index: event.index);
        emit(PlayerSeeked(event.position));
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerNext>((event, emit) async {
      try {
        await repository.seekToNext();
        emit(PlayerNexted());
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerPrevious>((event, emit) async {
      try {
        await repository.seekToPrevious();
        emit(PlayerPrevioussed());
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerSetVolume>((event, emit) async {
      try {
        await repository.setVolume(event.volume);
        emit(PlayerVolumeSet(event.volume));
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerSetSpeed>((event, emit) async {
      try {
        await repository.setSpeed(event.speed);
        emit(PlayerSpeedSet(event.speed));
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerSetLoopMode>((event, emit) async {
      try {
        await repository.setLoopMode(event.loopMode);
        emit(PlayerLoopModeSet(event.loopMode));
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });

    on<PlayerSetShuffleModeEnabled>((event, emit) async {
      try {
        await repository.setShuffleModeEnabled(event.shuffleModeEnabled);
        emit(PlayerShuffleModeEnabledSet(event.shuffleModeEnabled));
      } catch (e) {
        emit(PlayerError(e.toString()));
      }
    });
  }
}
