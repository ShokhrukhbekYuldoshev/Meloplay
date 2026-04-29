import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/src/core/helpers/helpers.dart';
import 'package:meloplay/src/features/playlists/data/repositories/song_repository.dart';
import 'package:meloplay/src/core/services/hive_box.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class MusicPlayer {
  Future<void> init();
  Future<void> load(MediaItem mediaItem, List<SongModel> playlist);
  MediaItem getMediaItemFromSong(SongModel song);
  Future<void> savePlaylist();
  Future<List<SongModel>> loadPlaylist();
  Future<void> setSequenceFromPlaylist(
    List<SongModel> playlist,
    SongModel lastPlayedSong,
  );
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position, {int? index});
  Future<void> seekToNext();
  Future<void> seekToPrevious();
  Stream<Duration> get position;
  Stream<Duration?> get duration;
  Stream<bool> get shuffleModeEnabled;
  Stream<LoopMode> get loopMode;
  Stream<bool> get playing;
  Stream<int?> get currentIndex;
  Stream<SequenceState?> get sequenceState;
  List<SongModel> get playlist;
  Stream<ProcessingState> get processingStateStream;
  Future<void> dispose();
  Future<void> setVolume(double volume);
  Future<void> setSpeed(double speed);
  Future<void> setShuffleModeEnabled(bool enabled);
  Future<void> setLoopMode(LoopMode loopMode);

  // Queue/Playlist management
  Future<void> addToQueue(SongModel song); // Add to end of playlist
  Future<void> addToQueueNext(SongModel song); // Add after current song
  Future<void> removeFromQueue(int index); // Remove from playlist
  Future<void> moveInQueue(int oldIndex, int newIndex); // Reorder playlist
  Future<void> clearQueue(); // Clear entire playlist
  List<SongModel> get queue; // Returns current playlist
  Stream<List<SongModel>> get queueStream;
  int get queueSize;
}

class JustAudioPlayer implements MusicPlayer {
  late final AudioPlayer _player;
  List<SongModel> _currentPlaylist = [];
  final StreamController<List<SongModel>> _queueController =
      StreamController<List<SongModel>>.broadcast();

  var box = Hive.box(HiveBox.boxName);

  // ==================== CONVERTER METHODS ====================

  Future<List<AudioSource>> _convertToAudioSources(
    List<SongModel> songs,
  ) async {
    return await Future.wait(
      songs.map((song) => _convertSingleToAudioSource(song)),
    );
  }

  Future<AudioSource> _convertSingleToAudioSource(SongModel song) async {
    return AudioSource.uri(
      Uri.parse(song.uri!),
      tag: MediaItem(
        id: song.id.toString(),
        title: song.title,
        album: song.album,
        artUri: Platform.isAndroid
            ? Uri.parse(
                'content://media/external/audio/albumart/${song.albumId}',
              )
            : null,
        artist: song.artist,
        duration: Duration(milliseconds: song.duration ?? 0),
      ),
    );
  }

  // ==================== QUEUE (PLAYLIST) METHODS ====================

  @override
  List<SongModel> get queue => List.unmodifiable(_currentPlaylist);

  @override
  Stream<List<SongModel>> get queueStream => _queueController.stream;

  @override
  int get queueSize => _currentPlaylist.length;

  /// Add song to the END of the playlist
  /// If song already exists, move it to the end instead of duplicating
  @override
  Future<void> addToQueue(SongModel song) async {
    final existingIndex = _currentPlaylist.indexWhere((s) => s.id == song.id);

    if (existingIndex != -1) {
      // Song exists - move it to the end
      await moveInQueue(existingIndex, _currentPlaylist.length - 1);
      showToast('Moved to end: ${song.title}');
    } else {
      // Song doesn't exist - add it
      _currentPlaylist.add(song);
      _queueController.add(_currentPlaylist);

      final newSource = await _convertSingleToAudioSource(song);
      await _player.addAudioSource(newSource);
      await savePlaylist();

      showToast('Added to queue: ${song.title}');
    }
  }

  /// Add song AFTER the currently playing song
  /// If song already exists, move it to after current instead of duplicating
  @override
  Future<void> addToQueueNext(SongModel song) async {
    final currentIndex = _player.currentIndex;
    if (currentIndex == null) {
      // Nothing playing, just add to end
      await addToQueue(song);
      return;
    }

    final insertIndex = currentIndex + 1;
    final existingIndex = _currentPlaylist.indexWhere((s) => s.id == song.id);

    if (existingIndex != -1) {
      // Song exists - move it to after current
      if (existingIndex == currentIndex) {
        // It's the current song - do nothing or move to next?
        showToast('Already playing: ${song.title}');
        return;
      }

      // Calculate new index considering removal
      int targetIndex = insertIndex;
      if (existingIndex < insertIndex) {
        targetIndex = insertIndex - 1;
      }
      await moveInQueue(existingIndex, targetIndex);
      showToast('Moved to play next: ${song.title}');
    } else {
      // Song doesn't exist - insert it
      _currentPlaylist.insert(insertIndex, song);
      _queueController.add(_currentPlaylist);

      final newSource = await _convertSingleToAudioSource(song);
      await _player.insertAudioSource(insertIndex, newSource);
      await savePlaylist();

      showToast('Added to play next: ${song.title}');
    }
  }

  /// Remove song from playlist at specific index
  @override
  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _currentPlaylist.length) {
      final song = _currentPlaylist.removeAt(index);
      _queueController.add(_currentPlaylist);

      await _player.removeAudioSourceAt(index);
      await savePlaylist();

      showToast('Removed from queue: ${song.title}');
    }
  }

  /// Move song from oldIndex to newIndex (reorder)
  @override
  Future<void> moveInQueue(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _currentPlaylist.length) return;
    if (newIndex < 0 || newIndex >= _currentPlaylist.length) return;

    final song = _currentPlaylist.removeAt(oldIndex);
    _currentPlaylist.insert(newIndex, song);
    _queueController.add(_currentPlaylist);

    await _player.moveAudioSource(oldIndex, newIndex);
    await savePlaylist();
  }

  /// Clear entire playlist AND stop playback
  @override
  Future<void> clearQueue() async {
    // Stop playback first
    await _player.stop();

    // Clear the playlist
    _currentPlaylist.clear();
    _queueController.add(_currentPlaylist);

    // Clear audio sources
    await _player.setAudioSources([]);
    await savePlaylist();

    showToast('Queue cleared');
  }

  // ==================== INIT & LOAD METHODS ====================

  @override
  Future<void> init() async {
    _player = AudioPlayer();

    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.sy.meloplay.channel.audio',
      androidNotificationChannelName: 'Meloplay',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );

    // Track recently played songs
    _player.currentIndexStream.listen((index) {
      if (index != null &&
          _currentPlaylist.isNotEmpty &&
          index < _currentPlaylist.length) {
        final songId = _currentPlaylist[index].id.toString();
        SongRepository().addToRecentlyPlayed(songId);
      }
    });

    // Load saved settings
    if (box.get(HiveBox.loopModeKey) != null) {
      _player.setLoopMode(LoopMode.values[box.get(HiveBox.loopModeKey)]);
    }
    if (box.get(HiveBox.shuffleModeKey) != null) {
      _player.setShuffleModeEnabled(box.get(HiveBox.shuffleModeKey));
    }

    // Load saved playlist
    final savedPlaylist = await loadPlaylist();
    if (savedPlaylist.isNotEmpty) {
      _currentPlaylist = savedPlaylist;
      _queueController.add(_currentPlaylist);
      final sources = await _convertToAudioSources(_currentPlaylist);
      await _player.setAudioSources(sources);
    }
  }

  @override
  Future<void> load(
    MediaItem mediaItem,
    List<SongModel> playlist, {
    bool play = true,
  }) async {
    try {
      _currentPlaylist = List.from(playlist);
      _queueController.add(_currentPlaylist);

      final sources = await _convertToAudioSources(_currentPlaylist);
      await _player.setAudioSources(sources);

      final initialIndex = _currentPlaylist.indexWhere(
        (song) => song.id.toString() == mediaItem.id,
      );

      if (initialIndex >= 0) {
        await _player.seek(Duration.zero, index: initialIndex);
      }

      await savePlaylist();

      if (play) {
        await _player.play();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading playlist: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> savePlaylist() async {
    await box.put(
      HiveBox.lastPlayedPlaylistKey,
      _currentPlaylist.map((song) => song.getMap).toList(),
    );
  }

  @override
  Future<List<SongModel>> loadPlaylist() async {
    List<dynamic> playlist = box.get(
      HiveBox.lastPlayedPlaylistKey,
      defaultValue: List.empty(),
    );
    return playlist.map((song) => SongModel(song)).toList();
  }

  // ==================== PLAYBACK CONTROL ====================

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position, {int? index}) async {
    if (index != null) {
      await _player.seek(position, index: index);
    } else {
      await _player.seek(position);
    }
  }

  @override
  Future<void> seekToNext() => _player.seekToNext();

  @override
  Future<void> seekToPrevious() => _player.seekToPrevious();

  // ==================== STREAMS ====================

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Stream<bool> get shuffleModeEnabled => _player.shuffleModeEnabledStream;

  @override
  Stream<LoopMode> get loopMode => _player.loopModeStream;

  @override
  Stream<bool> get playing => _player.playingStream;

  @override
  Stream<int?> get currentIndex => _player.currentIndexStream;

  @override
  Stream<SequenceState?> get sequenceState => _player.sequenceStateStream;

  @override
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  // ==================== SETTINGS ====================

  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setLoopMode(LoopMode loopMode) async {
    await box.put(HiveBox.loopModeKey, loopMode.index);
    await _player.setLoopMode(loopMode);
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    await box.put(HiveBox.shuffleModeKey, enabled);
    await _player.setShuffleModeEnabled(enabled);
  }

  // ==================== UTILITIES ====================

  @override
  MediaItem getMediaItemFromSong(SongModel song) {
    return MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: Duration(milliseconds: song.duration ?? 0),
    );
  }

  @override
  List<SongModel> get playlist => _currentPlaylist;

  @override
  Future<void> setSequenceFromPlaylist(
    List<SongModel> playlist,
    SongModel lastPlayedSong,
  ) async {
    await load(getMediaItemFromSong(lastPlayedSong), playlist, play: false);
  }

  @override
  Future<void> dispose() async {
    await _queueController.close();
    await _player.dispose();
  }
}
