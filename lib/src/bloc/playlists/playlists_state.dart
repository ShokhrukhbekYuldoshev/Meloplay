part of 'playlists_cubit.dart';

@immutable
sealed class PlaylistsState {}

final class PlaylistsInitial extends PlaylistsState {}

final class PlaylistsLoading extends PlaylistsState {}

final class PlaylistsLoaded extends PlaylistsState {
  final List<PlaylistModel> playlists;
  PlaylistsLoaded(this.playlists);
}

final class PlaylistsSongsLoading extends PlaylistsState {}

final class PlaylistsSongsLoaded extends PlaylistsState {
  final List<SongModel> songs;
  PlaylistsSongsLoaded(this.songs);
}
