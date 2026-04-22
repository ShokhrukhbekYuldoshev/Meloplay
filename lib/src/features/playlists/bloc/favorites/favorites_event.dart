part of 'favorites_bloc.dart';

@immutable
sealed class FavoritesEvent {}

class FetchFavorites extends FavoritesEvent {}
