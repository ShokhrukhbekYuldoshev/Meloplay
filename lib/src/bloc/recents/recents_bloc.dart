import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meloplay/src/data/repositories/recents_repository.dart';

import 'package:on_audio_query/on_audio_query.dart';

part 'recents_event.dart';
part 'recents_state.dart';

class RecentsBloc extends Bloc<RecentsEvent, RecentsState> {
  RecentsBloc({required RecentsRepository repository})
      : super(RecentsInitial()) {
    on<FetchRecents>((event, emit) async {
      emit(RecentsLoading());
      try {
        final favoriteSongs = await repository.fetchRecents();
        emit(RecentsLoaded(favoriteSongs));
      } catch (e) {
        emit(RecentsError(e.toString()));
      }
    });
  }
}
