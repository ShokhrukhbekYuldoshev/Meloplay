// lib/src/data/repositories/song_repository.dart
import 'package:hive/hive.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/services/hive_box.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongRepository {
  static const int maxRecentlyPlayed = 50;

  Box get _box => Hive.box(HiveBox.boxName);

  // ==================== FAVORITES ====================

  Future<void> toggleFavorite(String songId) async {
    final favorites = _getFavoriteIds();

    if (favorites.contains(songId)) {
      favorites.remove(songId);
    } else {
      favorites.add(songId);
    }

    await _box.put(HiveBox.favoriteSongsKey, favorites);
  }

  Future<void> addToFavorites(String songId) async {
    final favorites = _getFavoriteIds();
    if (!favorites.contains(songId)) {
      favorites.add(songId);
      await _box.put(HiveBox.favoriteSongsKey, favorites);
    }
  }

  Future<void> removeFromFavorites(String songId) async {
    final favorites = _getFavoriteIds();
    if (favorites.contains(songId)) {
      favorites.remove(songId);
      await _box.put(HiveBox.favoriteSongsKey, favorites);
    }
  }

  bool isFavorite(String songId) {
    return _getFavoriteIds().contains(songId);
  }

  Future<List<SongModel>> getFavoriteSongs() async {
    final favoriteIds = _getFavoriteIds();
    if (favoriteIds.isEmpty) return [];

    final allSongs = await _getAllSongs();
    return allSongs
        .where((song) => favoriteIds.contains(song.id.toString()))
        .toList();
  }

  // ==================== RECENTLY PLAYED ====================

  Future<void> addToRecentlyPlayed(String songId) async {
    final recents = _getRecentIds();

    recents.remove(songId);
    recents.insert(0, songId);

    // Keep only last 50
    if (recents.length > maxRecentlyPlayed) {
      recents.removeRange(maxRecentlyPlayed, recents.length);
    }

    await _box.put(HiveBox.recentlyPlayedSongsKey, recents);
  }

  Future<List<SongModel>> getRecentlyPlayedSongs() async {
    final recentIds = _getRecentIds();
    if (recentIds.isEmpty) return [];

    final allSongs = await _getAllSongs();
    final songs = allSongs
        .where((song) => recentIds.contains(song.id.toString()))
        .toList();

    // Sort by the order in recentIds
    songs.sort((a, b) {
      final indexA = recentIds.indexOf(a.id.toString());
      final indexB = recentIds.indexOf(b.id.toString());
      return indexA.compareTo(indexB);
    });

    return songs;
  }

  Future<SongModel?> getLastPlayedSong() async {
    final recents = await getRecentlyPlayedSongs();
    return recents.isNotEmpty ? recents.first : null;
  }

  Future<void> clearRecentlyPlayed() async {
    await _box.put(HiveBox.recentlyPlayedSongsKey, <String>[]);
  }

  // ==================== PRIVATE HELPERS ====================

  List<String> _getFavoriteIds() {
    final favorites = _box.get(HiveBox.favoriteSongsKey);
    if (favorites == null) return [];
    return List<String>.from(favorites);
  }

  List<String> _getRecentIds() {
    final recents = _box.get(HiveBox.recentlyPlayedSongsKey);
    if (recents == null) return [];
    return List<String>.from(recents);
  }

  Future<List<SongModel>> _getAllSongs() async {
    final audioQuery = sl<OnAudioQuery>();
    return await audioQuery.querySongs(uriType: UriType.EXTERNAL);
  }

  // ==================== UTILITY ====================

  Future<int> getFavoriteCount() async {
    return _getFavoriteIds().length;
  }

  Future<int> getRecentlyPlayedCount() async {
    return _getRecentIds().length;
  }

  Future<void> clearAll() async {
    await _box.put(HiveBox.favoriteSongsKey, <String>[]);
    await _box.put(HiveBox.recentlyPlayedSongsKey, <String>[]);
  }
}
