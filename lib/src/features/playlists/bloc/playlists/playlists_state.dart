part of 'playlists_cubit.dart';

@immutable
abstract class PlaylistsState {}

class PlaylistsInitial extends PlaylistsState {}

class PlaylistsLoading extends PlaylistsState {}

class PlaylistsLoaded extends PlaylistsState {
  final List<Playlist> playlists;

  PlaylistsLoaded(this.playlists);
}

class PlaylistsSongsLoaded extends PlaylistsState {
  final List<SongModel> songs;

  PlaylistsSongsLoaded(this.songs);
}

class PlaylistsError extends PlaylistsState {
  final String message;

  PlaylistsError({required this.message});
}

class PlaylistDeleted extends PlaylistsState {
  final int playlistId;

  PlaylistDeleted({required this.playlistId});
}

class PlaylistUpdated extends PlaylistsState {
  final int playlistId;

  PlaylistUpdated({required this.playlistId});
}
