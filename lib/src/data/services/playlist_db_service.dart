// lib/src/data/services/playlist_db_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meloplay/src/data/models/playlist_model.dart';
import 'package:meloplay/src/data/services/hive_box.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistDBService {
  Box? _playlistsBox;
  Box? _playlistSongsBox;

  static final PlaylistDBService _instance = PlaylistDBService._internal();
  factory PlaylistDBService() => _instance;
  PlaylistDBService._internal();

  bool get isInitialized => _playlistsBox != null && _playlistSongsBox != null;

  Future<void> init() async {
    if (isInitialized) return;

    await Hive.initFlutter();
    _playlistsBox = await Hive.openBox(HiveBox.playlistsBox);
    _playlistSongsBox = await Hive.openBox(HiveBox.playlistSongsBox);

    // Initialize counter if not exists
    if (_playlistsBox!.get(HiveBox.counterKey) == null) {
      await _playlistsBox!.put(HiveBox.counterKey, 0);
    }
  }

  Box get _playlistsBoxInstance {
    if (_playlistsBox == null) {
      throw Exception('PlaylistDBService not initialized. Call init() first.');
    }
    return _playlistsBox!;
  }

  Box get _playlistSongsBoxInstance {
    if (_playlistSongsBox == null) {
      throw Exception('PlaylistDBService not initialized. Call init() first.');
    }
    return _playlistSongsBox!;
  }

  Future<int> _getNextId() async {
    final counter = _playlistsBoxInstance.get(HiveBox.counterKey) as int;
    final nextId = counter + 1;
    await _playlistsBoxInstance.put(HiveBox.counterKey, nextId);
    return nextId;
  }

  // Playlist CRUD
  Future<List<Playlist>> getPlaylists() async {
    try {
      final playlists = <Playlist>[];
      final counter = _playlistsBoxInstance.get(HiveBox.counterKey) as int;

      for (int i = 1; i <= counter; i++) {
        final data = _playlistsBoxInstance.get(i);
        if (data != null) {
          playlists.add(
            Playlist(
              id: i,
              playlist: data['name'],
              numOfSongs: data['songCount'] ?? 0,
            ),
          );
        }
      }

      // Sort by creation date (newest first)
      playlists.sort((a, b) => b.id.compareTo(a.id));
      return playlists;
    } catch (e) {
      return [];
    }
  }

  Future<int> createPlaylist(String name) async {
    try {
      final id = await _getNextId();
      await _playlistsBoxInstance.put(id, {
        'name': name,
        'songCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> renamePlaylist(int id, String newName) async {
    try {
      final data = _playlistsBoxInstance.get(id);
      if (data != null) {
        data['name'] = newName;
        await _playlistsBoxInstance.put(id, data);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlaylist(int id) async {
    try {
      await _playlistsBoxInstance.delete(id);
      await _playlistSongsBoxInstance.delete(id.toString());
    } catch (e) {
      rethrow;
    }
  }

  // Playlist Songs CRUD
  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    try {
      final songs = <SongModel>[];
      final key = playlistId.toString();
      final songIds = _playlistSongsBoxInstance.get(key, defaultValue: <int>[]);

      if ((songIds as List).isEmpty) return [];

      // Get all songs and filter by IDs
      final allSongs = await OnAudioQuery().querySongs();
      for (var song in allSongs) {
        if (songIds.contains(song.id)) {
          songs.add(song);
        }
      }
      return songs;
    } catch (e) {
      return [];
    }
  }

  Future<void> addToPlaylist(int playlistId, SongModel song) async {
    try {
      final key = playlistId.toString();
      List<int> songIds = _playlistSongsBoxInstance.get(
        key,
        defaultValue: <int>[],
      );

      if (!songIds.contains(song.id)) {
        songIds.add(song.id);
        await _playlistSongsBoxInstance.put(key, songIds);
        await _updatePlaylistSongCount(playlistId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addMultipleToPlaylist(
    int playlistId,
    List<SongModel> songs,
  ) async {
    try {
      final key = playlistId.toString();
      List<int> songIds = _playlistSongsBoxInstance.get(
        key,
        defaultValue: <int>[],
      );
      bool hasChanges = false;

      for (var song in songs) {
        if (!songIds.contains(song.id)) {
          songIds.add(song.id);
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _playlistSongsBoxInstance.put(key, songIds);
        await _updatePlaylistSongCount(playlistId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromPlaylist(int playlistId, int songId) async {
    try {
      final key = playlistId.toString();
      List<int> songIds = _playlistSongsBoxInstance.get(
        key,
        defaultValue: <int>[],
      );

      if (songIds.remove(songId)) {
        await _playlistSongsBoxInstance.put(key, songIds);
        await _updatePlaylistSongCount(playlistId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMultipleFromPlaylist(
    int playlistId,
    List<int> songIds,
  ) async {
    try {
      final key = playlistId.toString();
      List<int> currentSongIds = _playlistSongsBoxInstance.get(
        key,
        defaultValue: <int>[],
      );
      bool hasChanges = false;

      for (var songId in songIds) {
        if (currentSongIds.remove(songId)) {
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _playlistSongsBoxInstance.put(key, currentSongIds);
        await _updatePlaylistSongCount(playlistId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearPlaylist(int playlistId) async {
    try {
      final key = playlistId.toString();
      await _playlistSongsBoxInstance.put(key, <int>[]);
      await _updatePlaylistSongCount(playlistId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updatePlaylistSongCount(int playlistId) async {
    try {
      final key = playlistId.toString();
      final songIds = _playlistSongsBoxInstance.get(key, defaultValue: <int>[]);
      final data = _playlistsBoxInstance.get(playlistId);

      if (data != null) {
        data['songCount'] = (songIds as List).length;
        await _playlistsBoxInstance.put(playlistId, data);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isSongInPlaylist(int playlistId, int songId) async {
    try {
      final key = playlistId.toString();
      final songIds = _playlistSongsBoxInstance.get(key, defaultValue: <int>[]);
      return (songIds as List).contains(songId);
    } catch (e) {
      return false;
    }
  }

  Future<int> getPlaylistSongCount(int playlistId) async {
    try {
      final key = playlistId.toString();
      final songIds = _playlistSongsBoxInstance.get(key, defaultValue: <int>[]);
      return (songIds as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getPlaylistDetails(int playlistId) async {
    try {
      return _playlistsBoxInstance.get(playlistId);
    } catch (e) {
      return null;
    }
  }

  // Utility method to reset all data (for debugging)
  Future<void> resetAllData() async {
    try {
      await _playlistsBoxInstance.clear();
      await _playlistSongsBoxInstance.clear();
      await _playlistsBoxInstance.put(HiveBox.counterKey, 0);
    } catch (e) {
      rethrow;
    }
  }
}
