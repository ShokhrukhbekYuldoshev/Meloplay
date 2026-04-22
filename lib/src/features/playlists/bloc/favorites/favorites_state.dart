part of 'favorites_bloc.dart';

@immutable
sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

final class FavoritesLoading extends FavoritesState {}

final class FavoritesLoaded extends FavoritesState {
  final List<SongModel> favoriteSongs;
  FavoritesLoaded(this.favoriteSongs);
}

final class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
