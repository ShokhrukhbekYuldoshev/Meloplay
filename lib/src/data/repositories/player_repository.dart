import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class JustAudioPlayer {
  Future<void> init();
  Future<void> load(
    MediaItem mediaItem,
    List<SongModel> playlist,
  );
  MediaItem getMediaItemFromSong(SongModel song);
  SongModel getSongModelFromMediaItem(MediaItem mediaItem);
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
}

class JustAudioPlayerImpl implements JustAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> currentPlaylist = [];

  @override
  Future<void> init() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.shokhrukhbek.meloplay.channel.audio',
      androidNotificationChannelName: 'Meloplay',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  }

  @override
  Future<void> load(
    MediaItem mediaItem,
    List<SongModel> playlist,
  ) async {
    List<AudioSource> sources = [];

    for (var song in playlist) {
      var artUri = 'content://media/external/audio/albumart/';

      if (song.albumId != null) {
        artUri += song.albumId.toString();
      }

      sources.add(
        AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            title: song.title,
            album: song.album,
            artUri: Platform.isAndroid ? Uri.parse(artUri) : null,
            artist: song.artist,
            duration: Duration(milliseconds: song.duration!),
            genre: song.genre,
          ),
        ),
      );
    }

    int initialIndex = 0;

    for (int i = 0; i < playlist.length; i++) {
      if (playlist[i].id.toString() == mediaItem.id) {
        initialIndex = i;
        break;
      }
    }

    await _player.setAudioSource(
      initialIndex: initialIndex,
      ConcatenatingAudioSource(
        children: sources,
      ),
    );

    currentPlaylist = playlist;
    await _player.play();
  }

  @override
  MediaItem getMediaItemFromSong(SongModel song) {
    return MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: Duration(milliseconds: song.duration!),
      // artUri: Uri.parse(song.uri!),
    );
  }

  @override
  SongModel getSongModelFromMediaItem(MediaItem mediaItem) {
    return SongModel({
      'id': int.parse(mediaItem.id),
      'title': mediaItem.title,
      'artist': mediaItem.artist,
      'album': mediaItem.album,
      'duration': mediaItem.duration?.inMilliseconds,
      'uri': mediaItem.extras!['url'],
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position, {int? index}) async {
    if (index != null) {
      await _player.seek(
        position,
        index: index,
      );
    } else {
      await _player.seek(position);
    }
  }

  @override
  Future<void> seekToNext() => _player.seekToNext();

  @override
  Future<void> seekToPrevious() => _player.seekToPrevious();

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  // shuffle mode enabled
  Stream<bool> get shuffleModeEnabled => _player.shuffleModeEnabledStream;

  @override
  // loop mode
  Stream<LoopMode> get loopMode => _player.loopModeStream;

  @override
  Future<void> dispose() async => await _player.dispose();

  @override
  Stream<bool> get playing => _player.playingStream;

  @override
  Stream<int?> get currentIndex => _player.currentIndexStream;

  @override
  Stream<SequenceState?> get sequenceState => _player.sequenceStateStream;

  @override
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

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
    await _player.setLoopMode(loopMode);
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  List<SongModel> get playlist => currentPlaylist;
}
