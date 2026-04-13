import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meloplay/src/data/models/playlist_model.dart';
import 'package:meloplay/src/data/services/playlist_db_service.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'playlists_state.dart';

class PlaylistsCubit extends Cubit<PlaylistsState> {
  PlaylistsCubit() : super(PlaylistsInitial());

  final PlaylistDBService _dbService = PlaylistDBService();

  Future<void> queryPlaylists() async {
    try {
      emit(PlaylistsLoading());
      final playlists = await _dbService.getPlaylists();
      emit(PlaylistsLoaded(playlists));
    } catch (e) {
      emit(
        PlaylistsError(message: 'Failed to load playlists: ${e.toString()}'),
      );
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      emit(PlaylistsLoading());
      await _dbService.createPlaylist(name);
      await queryPlaylists();
    } catch (e) {
      emit(
        PlaylistsError(message: 'Failed to create playlist: ${e.toString()}'),
      );
    }
  }

  Future<void> queryPlaylistSongs(int playlistId) async {
    try {
      emit(PlaylistsLoading());

      // Get songs from local database
      final songs = await _dbService.getPlaylistSongs(playlistId);

      emit(PlaylistsSongsLoaded(songs));
    } catch (e) {
      emit(
        PlaylistsError(
          message: 'Failed to load playlist songs: ${e.toString()}',
        ),
      );
    }
  }

  // Update addToPlaylist and removeFromPlaylist in PlaylistsCubit
  Future<void> addToPlaylist(int playlistId, SongModel song) async {
    try {
      emit(PlaylistsLoading());
      await _dbService.addToPlaylist(playlistId, song);
      await queryPlaylistSongs(playlistId);
      emit(PlaylistUpdated(playlistId: playlistId)); // Emit this
    } catch (e) {
      emit(
        PlaylistsError(
          message: 'Failed to add song to playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> removeFromPlaylist(int playlistId, int songId) async {
    try {
      emit(PlaylistsLoading());
      await _dbService.removeFromPlaylist(playlistId, songId);
      await queryPlaylistSongs(playlistId);
      emit(PlaylistUpdated(playlistId: playlistId));
    } catch (e) {
      emit(
        PlaylistsError(
          message: 'Failed to remove song from playlist: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    try {
      emit(PlaylistsLoading());
      await _dbService.deletePlaylist(playlistId);
      await queryPlaylists();
    } catch (e) {
      emit(
        PlaylistsError(message: 'Failed to delete playlist: ${e.toString()}'),
      );
    }
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    try {
      emit(PlaylistsLoading());
      await _dbService.renamePlaylist(playlistId, newName);
      emit(PlaylistUpdated(playlistId: playlistId));
    } catch (e) {
      emit(
        PlaylistsError(message: 'Failed to rename playlist: ${e.toString()}'),
      );
    }
  }

  Future<bool> isSongInPlaylist(int playlistId, int songId) async {
    return await _dbService.isSongInPlaylist(playlistId, songId);
  }
}
