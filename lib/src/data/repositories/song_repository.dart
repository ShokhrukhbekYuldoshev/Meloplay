import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongRepository {
  SongRepository() {
    _loadEmptyPlaylist();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await audioPlayer.setAudioSource(playlist);
    } catch (err) {
      debugPrint("Error: $err");
    }
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  bool arePlaylistsEqual(
      ConcatenatingAudioSource a, ConcatenatingAudioSource b) {
    if (a.children.length != b.children.length) {
      return false;
    }

    for (int i = 0; i < a.children.length; i++) {
      UriAudioSource sourceA = a.children[i] as UriAudioSource;
      UriAudioSource sourceB = b.children[i] as UriAudioSource;

      if (sourceA.uri != sourceB.uri) {
        return false;
      }
    }

    return true;
  }

  final audioPlayer = AudioPlayer();

  // playlist
  final playlist = ConcatenatingAudioSource(children: []);

  // media items
  var mediaItems = <MediaItem>[];

  // add songs to playlist
  Future<void> addSongsToPlaylist(List<SongModel> songs) async {
    final mediaItems = getMediaItemsFromSongs(songs);
    this.mediaItems = mediaItems;

    var temp = ConcatenatingAudioSource(children: []);

    await temp.addAll(mediaItems.map((mediaItem) {
      final source = _createAudioSource(mediaItem);
      return source;
    }).toList());

    if (!arePlaylistsEqual(playlist, temp)) {
      playlist.clear();
      playlist.addAll(temp.children);
      await audioPlayer.setAudioSource(temp);
    }
  }

  // media item to song model
  SongModel getSongFromMediaItem(MediaItem mediaItem) {
    return SongModel({
      'id': int.parse(mediaItem.id),
      'title': mediaItem.title,
      'artist': mediaItem.artist,
      'album': mediaItem.album,
      'duration': mediaItem.duration?.inMilliseconds,
      'uri': mediaItem.extras!['url'],
    });
  }

  // media items to song models
  List<SongModel> getSongsFromMediaItems(List<MediaItem> mediaItems) {
    return mediaItems
        .map((mediaItem) => getSongFromMediaItem(mediaItem))
        .toList();
  }

  // song model to media item
  MediaItem getMediaItemFromSong(SongModel song) {
    return MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: Duration(milliseconds: song.duration!),
      // artUri: uri,
      extras: {
        'url': song.uri,
      },
    );
  }

  // song models to media items
  List<MediaItem> getMediaItemsFromSongs(List<SongModel> songs) {
    return songs.map((song) => getMediaItemFromSong(song)).toList();
  }

  // current index
  Stream<int?> get currentIndex => audioPlayer.currentIndexStream;

  // current media item
  Stream<MediaItem?> get mediaItem => mediaItems.isEmpty
      ? Stream.value(null)
      : audioPlayer.currentIndexStream.map((index) => mediaItems[index!]);

  // current position
  Stream<Duration> get position => audioPlayer.positionStream;

  // duration
  Stream<Duration?> get duration => audioPlayer.durationStream;

  // shuffle mode enabled
  Stream<bool> get shuffleModeEnabled => audioPlayer.shuffleModeEnabledStream;

  // loop mode
  Stream<LoopMode> get loopMode => audioPlayer.loopModeStream;

  // playing
  Stream<bool> get playing => audioPlayer.playingStream;

  // play
  Future<void> play() async {
    await audioPlayer.play();
  }

  // play from queue
  Future<void> playFromQueue(int index) async {
    await audioPlayer.seek(Duration.zero, index: index);
    await audioPlayer.play();
  }

  int getMediaItemIndex(MediaItem mediaItem) {
    return mediaItems.indexWhere((item) => item == mediaItem);
  }

  int getMediaItemId(MediaItem mediaItem) {
    return mediaItems.indexWhere((item) => item.id == mediaItem.id);
  }

  // pause
  Future<void> pause() async {
    await audioPlayer.pause();
  }

  // stop
  Future<void> stop() async {
    await audioPlayer.stop();
  }

  // dispose
  Future<void> dispose() async {
    await audioPlayer.dispose();
  }

  // seek next
  Future<void> seekNext() async {
    await audioPlayer.seekToNext();
  }

  // seek previous
  Future<void> seekPrevious() async {
    // if first song, seek to last song
    if (audioPlayer.currentIndex == 0) {
      await audioPlayer.seek(Duration.zero, index: playlist.length - 1);
    } else {
      await audioPlayer.seekToPrevious();
    }
  }

  // seek
  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  // set volume
  Future<void> setVolume(double volume) async {
    await audioPlayer.setVolume(volume);
  }

  // set speed
  Future<void> setSpeed(double speed) async {
    await audioPlayer.setSpeed(speed);
  }

  // set loop mode
  Future<void> setLoopMode(LoopMode loopMode) async {
    await audioPlayer.setLoopMode(loopMode);
  }

  // set shuffle mode
  Future<void> setShuffleModeEnabled(bool enabled) async {
    await audioPlayer.setShuffleModeEnabled(enabled);
  }
}
