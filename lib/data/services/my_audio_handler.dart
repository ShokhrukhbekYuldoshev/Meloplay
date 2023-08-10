import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler {
  /// An instance of the AudioPlayer class, which is part of the just_audio package.
  /// It is responsible for managing audio playback, including playing, pausing,
  /// seeking, buffering, and more.
  final _player = AudioPlayer();

  /// An instance of the ConcatenatingAudioSource class, which is part of the just_audio
  /// package. It allows you to concatenate multiple audio sources (e.g., songs) to
  /// create a continuous playlist. The children parameter is an empty list of audio
  /// sources when initializing the instance, but it can be updated with new
  /// audio sources as needed.
  final _songQueue = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_songQueue);
    } catch (err) {
      debugPrint("Error: $err");
    }
  }

  /// Starts or resumes the playback of the current audio item in the queue.
  /// If the playback is already in progress, this method has no effect.
  ///
  /// Returns: A Future<void> that completes when the playback has started or resumed.
  @override
  Future<void> play() => _player.play();

  /// Pauses the playback of the current audio item. If the playback is already
  /// paused or stopped, this method has no effect.
  ///
  /// Returns: A Future<void> that completes when the playback has been paused.
  @override
  Future<void> pause() => _player.pause();

  /// Seeks the playback position of the current audio item to the specified Duration position.
  /// This method allows for both forward and backward seeking. If the provided position is
  /// out of bounds (less than 0 or greater than the audio item's duration), the player
  /// will automatically adjust it within the valid range.
  ///
  /// Returns: A Future<void> that completes when the seek operation has been performed.
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Stops the playback of the current audio item and resets the player position to
  /// the beginning of the item. If the playback is already stopped, this method has no effect.
  ///
  /// Returns: A Future<void> that completes when the playback has been stopped.
  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  /// Adds a new MediaItem to the end of the playback queue. The provided mediaItem
  /// must have a valid URI in its extras field. Once the item is added, the
  /// playback queue is updated.
  ///
  /// Returns: A Future<void> that completes when the MediaItem has been added
  /// to the playback queue.
  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final audioSource = _createAudioSource(mediaItem);
    _songQueue.add(audioSource);

    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  /// Removes a MediaItem from the playback queue at the specified index. If the
  /// index is out of range, this method has no effect. Once the item is removed,
  /// the playback queue is updated.
  ///
  /// Returns: A Future<void> that completes when the MediaItem has been removed
  /// from the playback queue or when the index is out of range.
  @override
  Future<void> removeQueueItemAt(int index) async {
    if (_songQueue.length > index) {
      _songQueue.removeAt(index);

      final newQueue = queue.value..removeAt(index);
      queue.add(newQueue);
    }
  }

  /// Creates a UriAudioSource instance from the given MediaItem. It takes the MediaItem
  /// as input, extracts the audio URL from its extras field, and returns a new
  /// UriAudioSource with the audio URL and the MediaItem itself as the tag.
  ///
  /// Returns: A UriAudioSource object containing the audio URL and the MediaItem as the tag.
  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  /// Transforms a PlaybackEvent from the just_audio player into an audio_service PlaybackState.
  /// This is done by creating a new PlaybackState instance with appropriate controls,
  /// system actions, processing state, and other information derived from the just_audio player.
  ///
  /// Returns: A PlaybackState object that represents the current state of the audio
  /// playback in the audio_service format.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
      shuffleMode: _player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: _player.loopMode == LoopMode.one
          ? AudioServiceRepeatMode.one
          : _player.loopMode == LoopMode.all
              ? AudioServiceRepeatMode.all
              : AudioServiceRepeatMode.none,
    );
  }

  /// Listens for changes in the duration of the currently playing audio track using the _player.durationStream.
  /// When a duration change is detected, it updates the duration of the corresponding MediaItem
  ///  in the queue and notifies the audio_service clients about the change.
  ///
  /// Note: This method is called in the MyAudioHandler constructor to start listening for duration changes.
  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  /// Listens for changes in the current song index in the queue using the
  /// _player.currentIndexStream. When a change is detected, it updates the current MediaItem
  /// in the audio_service clients.
  ///
  /// Note: This method is called in the MyAudioHandler constructor to start listening for current song index changes.
  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      mediaItem.add(playlist[index]);
    });
  }

  /// Listens for changes in the sequence state of the audio player using the _player.sequenceStateStream.
  /// When a change is detected, it updates the queue in the audio_service clients accordingly.
  ///
  /// Note: This method is called in the MyAudioHandler constructor to start listening for sequence state changes.
  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  // Skipping to the next item in the queue
  @override
  Future<void> skipToNext() {
    // if last song, then start from beginning
    if (_player.currentIndex! + 1 == queue.value.length) {
      return skipToQueueItem(0);
    } else {
      return _player.seekToNext();
    }
  }

  // Skipping to the previous item in the queue
  @override
  Future<void> skipToPrevious() {
    // if first song, then start from beginning
    if (_player.currentIndex == 0) {
      return skipToQueueItem(queue.value.length - 1);
    } else {
      return _player.seekToPrevious();
    }
  }

  // Skipping to a specific item in the queue
  @override
  Future<void> skipToQueueItem(int index) async {
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final newMode = {
      AudioServiceShuffleMode.none: false,
      AudioServiceShuffleMode.all: true,
    }[shuffleMode]!;
    await _player.setShuffleModeEnabled(newMode);

    // ! TODO: Fix this hack
    // This is a hack to get the player to emit a sequenceState event with the
    // new shuffle mode. Without this, the UI will not update to reflect the
    // new shuffle mode.
    bool playing = _player.playerState.playing;
    if (playing) {
      await _player.pause();
      await _player.play();
    } else {
      await _player.play();
      await _player.pause();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final LoopMode newMode = {
      AudioServiceRepeatMode.none: LoopMode.off,
      AudioServiceRepeatMode.one: LoopMode.one,
      AudioServiceRepeatMode.all: LoopMode.all,
    }[repeatMode]!;
    await _player.setLoopMode(newMode);

    // ! TODO: Fix this hack
    // This is a hack to get the player to emit a sequenceState event with the
    // new shuffle mode. Without this, the UI will not update to reflect the
    // new shuffle mode.
    bool playing = _player.playerState.playing;

    if (playing) {
      await _player.pause();
      await _player.play();
    } else {
      await _player.play();
      await _player.pause();
    }
  }
}
