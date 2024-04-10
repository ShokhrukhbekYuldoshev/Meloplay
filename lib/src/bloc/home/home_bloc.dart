import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/data/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required HomeRepository repository}) : super(HomeInitial()) {
    on<GetSongsEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final songs = await repository.getSongs();
        emit(
          SongsLoaded(songs),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
    on<GetArtistsEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final artists = await repository.getArtists();
        emit(
          ArtistsLoaded(artists),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
    on<GetAlbumsEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final albums = await repository.getAlbums();
        emit(
          AlbumsLoaded(albums),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
    on<GetGenresEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final genres = await repository.getGenres();
        emit(
          GenresLoaded(genres),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
    on<SortSongsEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        await repository.sortSongs(event.songSortType, event.orderType);
        final songs = await repository.getSongs();
        emit(
          SongsLoaded(songs),
        );
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);
        emit(HomeError(e.toString()));
      }
    });
  }
}
