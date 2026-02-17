part of 'home_bloc.dart';

@immutable
class HomeState {
  final bool isLoading;

  final List<SongModel> songs;
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<GenreModel> genres;

  final String? error;

  const HomeState({
    this.isLoading = false,
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.genres = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<SongModel>? songs,
    List<ArtistModel>? artists,
    List<AlbumModel>? albums,
    List<GenreModel>? genres,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      songs: songs ?? this.songs,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
      genres: genres ?? this.genres,
      error: error,
    );
  }
}
