import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/src/features/playlists/data/repositories/song_repository.dart';

import 'package:on_audio_query/on_audio_query.dart';

part 'recents_event.dart';
part 'recents_state.dart';

class RecentsBloc extends Bloc<RecentsEvent, RecentsState> {
  RecentsBloc({required SongRepository repository}) : super(RecentsInitial()) {
    on<FetchRecents>((event, emit) async {
      emit(RecentsLoading());
      try {
        final recentSongs = await repository.getRecentlyPlayedSongs();
        emit(RecentsLoaded(recentSongs));
      } catch (e) {
        emit(RecentsError(e.toString()));
      }
    });
  }
}
