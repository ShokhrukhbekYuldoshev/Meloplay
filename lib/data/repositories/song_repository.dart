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

  // get queue
  ValueStream<List<MediaItem>> get queue => _audioHandler.queue;

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

  void play() => _audioHandler.play();

  void playFromMediaId(String mediaId) =>
      _audioHandler.playFromMediaId(mediaId);

  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void stop() => _audioHandler.stop();

  void addQueueItem(MediaItem mediaItem) =>
      _audioHandler.addQueueItem(mediaItem);

  void removeQueueItemAt(int index) => _audioHandler.removeQueueItemAt(index);

  void skipToNext() => _audioHandler.skipToNext();

  void skipToPrevious() => _audioHandler.skipToPrevious();

  void skipToQueueItem(int index) => _audioHandler.skipToQueueItem(index);

  void fastForward() => _audioHandler.fastForward();

  void rewind() => _audioHandler.rewind();

  void setSpeed(double speed) => _audioHandler.setSpeed(speed);

  void setRepeatMode(AudioServiceRepeatMode repeatMode) =>
      _audioHandler.setRepeatMode(repeatMode);

  void setShuffleMode(AudioServiceShuffleMode shuffleMode) =>
      _audioHandler.setShuffleMode(shuffleMode);

  // current position
  Stream<Duration> get position => AudioService.position.map((event) => event);

  // current playback state
  Stream<PlaybackState> get playbackState => _audioHandler.playbackState;

  // current shuffle mode
  Stream<AudioServiceShuffleMode> get shuffleMode =>
      _audioHandler.playbackState.map((state) => state.shuffleMode);

  // play media item from queue
  void playFromQueue(MediaItem mediaItem) {
    int index = getMediaItemIndexFromQueue(mediaItem);
    if (index != -1) {
      skipToQueueItem(index);
    }

    play();
  }
}
