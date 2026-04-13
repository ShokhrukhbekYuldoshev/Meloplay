import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/data/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(const HomeState()) {
    /// =========================
    /// GET SONGS
    /// =========================
    on<GetSongsEvent>((event, emit) async {
      // Prevent unnecessary reload
      // if (state.songs.isNotEmpty) return;

      emit(state.copyWith(isLoading: true));

      try {
        final songs = await repository.getSongs();

        emit(state.copyWith(isLoading: false, songs: songs));
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);

        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    /// =========================
    /// SORT SONGS
    /// =========================
    on<SortSongsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await repository.sortSongs(event.songSortType, event.orderType);
        final songs = await repository.getSongs();

        emit(state.copyWith(isLoading: false, songs: songs));
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);

        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    /// =========================
    /// GET ARTISTS
    /// =========================
    on<GetArtistsEvent>((event, emit) async {
      if (state.artists.isNotEmpty) return;

      emit(state.copyWith(isLoading: true));

      try {
        final artists = await repository.getArtists();

        emit(state.copyWith(isLoading: false, artists: artists));
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);

        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    /// =========================
    /// GET ALBUMS
    /// =========================
    on<GetAlbumsEvent>((event, emit) async {
      if (state.albums.isNotEmpty) return;

      emit(state.copyWith(isLoading: true));

      try {
        final albums = await repository.getAlbums();

        emit(state.copyWith(isLoading: false, albums: albums));
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);

        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    /// =========================
    /// GET GENRES
    /// =========================
    on<GetGenresEvent>((event, emit) async {
      if (state.genres.isNotEmpty) return;

      emit(state.copyWith(isLoading: true));

      try {
        final genres = await repository.getGenres();

        emit(state.copyWith(isLoading: false, genres: genres));
      } catch (e, s) {
        debugPrintStack(label: e.toString(), stackTrace: s);

        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}
