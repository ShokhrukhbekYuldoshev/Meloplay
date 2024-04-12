import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'playlists_state.dart';

class PlaylistsCubit extends Cubit<PlaylistsState> {
  PlaylistsCubit() : super(PlaylistsInitial());

  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<PlaylistModel> playlists = [];

  Future<void> queryPlaylists() async {
    emit(PlaylistsLoading());
    playlists = await _audioQuery.queryPlaylists();
    emit(PlaylistsLoaded(playlists));
  }

  Future<void> createPlaylist(String name) async {
    emit(PlaylistsLoading());
    await _audioQuery.createPlaylist(name);
    playlists = await _audioQuery.queryPlaylists();
    emit(PlaylistsLoaded(playlists));
  }

  Future<void> queryPlaylistSongs(int playlistId) async {
    emit(PlaylistsLoading());
    List<SongModel> playlistSongs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      playlistId,
    );

    // TODO: NOTE: this is just a workaround. on_audio_query has a bug that changes songs' _uri and id
    List<SongModel> allSongs = await _audioQuery.querySongs();
    allSongs.removeWhere(
      (song) => !playlistSongs.any((element) => element.data == song.data),
    );

    emit(PlaylistsSongsLoaded(allSongs));
  }

  Future<void> addToPlaylist(int playlistId, SongModel song) async {
    emit(PlaylistsLoading());
    await _audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      playlistId,
    );

    await _audioQuery.addToPlaylist(playlistId, song.id);
    await queryPlaylistSongs(playlistId);
  }

  // TODO: NOTE: Doesn't work. on_audio_query has a bug
  // Future<void> removeFromPlaylist(
  //   int playlistId,
  //   int songId,
  // ) async {
  //   emit(PlaylistsLoading());
  //   await _audioQuery.removeFromPlaylist(playlistId, songId);
  //   await queryPlaylistSongs(playlistId);
  // }

  Future<void> deletePlaylist(int playlistId) async {
    emit(PlaylistsLoading());
    await _audioQuery.removePlaylist(playlistId);
    playlists = await _audioQuery.queryPlaylists();
    emit(PlaylistsLoaded(playlists));
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    emit(PlaylistsLoading());
    await _audioQuery.renamePlaylist(playlistId, newName);
    playlists = await _audioQuery.queryPlaylists();
    emit(PlaylistsLoaded(playlists));
  }
}
