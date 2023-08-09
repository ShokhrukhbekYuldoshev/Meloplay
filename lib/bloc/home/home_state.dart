part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class SongsLoaded extends HomeState {
  final List<SongModel> songs;

  SongsLoaded(this.songs);
}

final class ArtistsLoaded extends HomeState {
  final List<ArtistModel> artists;

  ArtistsLoaded(this.artists);
}

final class AlbumsLoaded extends HomeState {
  final List<AlbumModel> albums;

  AlbumsLoaded(this.albums);
}

final class GenresLoaded extends HomeState {
  final List<GenreModel> genres;

  GenresLoaded(this.genres);
}

final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
