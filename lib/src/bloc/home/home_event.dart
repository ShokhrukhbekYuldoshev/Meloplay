part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

// songs, artists, albums, genres
class GetSongsEvent extends HomeEvent {}

class GetArtistsEvent extends HomeEvent {}

class GetAlbumsEvent extends HomeEvent {}

class GetGenresEvent extends HomeEvent {}
