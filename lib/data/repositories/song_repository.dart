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

  final audioPlayer = AudioPlayer();

  // playlist
  final playlist = ConcatenatingAudioSource(children: []);

  // media items
  var mediaItems = <MediaItem>[];

  // add songs to playlist
  Future<void> addSongsToPlaylist(List<SongModel> songs) async {
    final mediaItems = songs.map((song) => getMediaItemFromSong(song)).toList();
    this.mediaItems = [...mediaItems];

    await playlist.addAll(mediaItems.map((mediaItem) {
      final source = _createAudioSource(mediaItem);
      return source;
    }).toList());
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

  // current index
  Stream<int?> get currentIndex => audioPlayer.currentIndexStream;

  // current media item
  Stream<MediaItem?> get mediaItem => mediaItems.isEmpty
      ? Stream.value(null)
      : audioPlayer.currentIndexStream.map((index) => mediaItems[index!]);

  // current position
  Stream<Duration> get position => audioPlayer.positionStream;

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
    return mediaItems.indexWhere((item) => item.id == mediaItem.id);
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

  // seek next
  Future<void> seekNext() async {
    // if last song, seek to first song
    if (audioPlayer.currentIndex == playlist.length - 1) {
      await audioPlayer.seek(Duration.zero, index: 0);
    } else {
      await audioPlayer.seekToNext();
    }
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
