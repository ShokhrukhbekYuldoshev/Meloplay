import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class SongRepository {
  SongRepository({required AudioHandler audioHandler})
      : _audioHandler = audioHandler;

  final AudioHandler _audioHandler;
  // final audioQuery = OnAudioQuery();

  // current media item
  ValueStream<MediaItem?> get mediaItem => _audioHandler.mediaItem;

  // current position
  Stream<Duration> get position => AudioService.position.map((event) => event);

  // current playback state
  ValueStream<PlaybackState> get playbackState => _audioHandler.playbackState;

  // get queue
  ValueStream<List<MediaItem>> get queue => _audioHandler.queue;

  // get media item index from queue
  int getMediaItemIndexFromQueue(MediaItem mediaItem) {
    int index = 0;
    for (MediaItem item in _audioHandler.queue.value) {
      if (item.id == mediaItem.id) {
        return index;
      }
      index++;
    }
    return -1;
  }

  // uint8list to uri
  // Future<Uri?> getArtwork(int id) async {
  //   Uint8List? artwork = await audioQuery.queryArtwork(
  //     id,
  //     ArtworkType.AUDIO,
  //   );
  //   Uri? uri;
  //   if (artwork != null) {
  //     uri = Uri.dataFromBytes(artwork);
  //   }
  //   return uri;
  // }

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

  Future<void> addSongsToQueue(List<SongModel> songs) async {
    // clear queue
    await clearQueue();

    // create media items
    List<MediaItem> mediaItems = [];

    for (SongModel song in songs) {
      mediaItems.add(getMediaItemFromSong(song));
    }

    // add songs to queue
    for (MediaItem mediaItem in mediaItems) {
      await _audioHandler.addQueueItem(mediaItem);
    }
  }

  Future<void> clearQueue() async {
    for (int i = 0; i < _audioHandler.queue.value.length; i++) {
      await _audioHandler.removeQueueItemAt(i);
    }
  }

  Future<void> play() => _audioHandler.play();

  Future<void> pause() => _audioHandler.pause();

  Future<void> seek(Duration position) => _audioHandler.seek(position);

  Future<void> stop() => _audioHandler.stop();

  Future<void> addQueueItem(MediaItem mediaItem) =>
      _audioHandler.addQueueItem(mediaItem);

  Future<void> removeQueueItemAt(int index) =>
      _audioHandler.removeQueueItemAt(index);

  Future<void> skipToNext() => _audioHandler.skipToNext();

  Future<void> skipToPrevious() => _audioHandler.skipToPrevious();

  Future<void> skipToQueueItem(int index) =>
      _audioHandler.skipToQueueItem(index);

  Future<void> fastForward() => _audioHandler.fastForward();

  Future<void> rewind() => _audioHandler.rewind();

  Future<void> setSpeed(double speed) => _audioHandler.setSpeed(speed);

  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) =>
      _audioHandler.setRepeatMode(repeatMode);

  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) =>
      _audioHandler.setShuffleMode(shuffleMode);

  // play media item from queue
  void playFromQueue(MediaItem mediaItem) {
    int index = getMediaItemIndexFromQueue(mediaItem);
    if (index != -1) {
      skipToQueueItem(index);
    }

    play();
  }
}
