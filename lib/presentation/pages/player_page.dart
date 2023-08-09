import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meloplay/data/repositories/song_repository.dart';
import 'package:meloplay/presentation/components/animated_favorite_button.dart';
import 'package:meloplay/presentation/utils/extensions.dart';
import 'package:meloplay/presentation/utils/theme/themes.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerPage extends StatefulWidget {
  final MediaItem mediaItem;
  const PlayerPage({
    Key? key,
    required this.mediaItem,
  }) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final SongRepository songRepository;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    songRepository = context.read<SongRepository>();

    // if media item is same skip
    if (songRepository.mediaItem.value?.id != widget.mediaItem.id) {
      songRepository.playFromQueue(widget.mediaItem);
    } else {
      songRepository.play();
    }

    songRepository.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        if (mounted) {
          setState(() {
            _duration = mediaItem.duration ?? Duration.zero;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        padding: EdgeInsets.fromLTRB(
          32,
          MediaQuery.of(context).padding.top + 16,
          32,
          16,
        ),
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: Column(
          children: [
            // back button
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // artwork
            songRepository.mediaItem.value == null
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    flex: 3,
                    child: QueryArtworkWidget(
                      id: int.parse(songRepository.mediaItem.value!.id),
                      type: ArtworkType.AUDIO,
                      artworkQuality: FilterQuality.high,
                      quality: 100,
                      nullArtworkWidget: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.music_note_outlined,
                          size: MediaQuery.of(context).size.height / 10,
                        ),
                      ),
                      artworkBorder: BorderRadius.circular(10),
                      artworkWidth: double.infinity,
                      artworkHeight: MediaQuery.of(context).size.width - 64,
                      artworkFit: BoxFit.fill,
                    ),
                  ),
            const Spacer(),
            // title and artist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songRepository.mediaItem.value?.title ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        songRepository.mediaItem.value?.artist ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedFavoriteButton(
                  isFavorite: false,
                  onChanged: (value) {},
                ),
              ],
            ),
            const Spacer(),
            // seek bar
            StreamBuilder<Duration>(
              stream: songRepository.position,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;

                return Slider(
                  value: position.inMilliseconds.toDouble(),
                  min: 0,
                  max: _duration?.inMilliseconds.toDouble() ?? 0,
                  onChanged: (value) {
                    songRepository.seek(Duration(milliseconds: value.toInt()));
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            // time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<Duration>(
                  stream: songRepository.position,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;

                    return Text(
                      position.toHms(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                Text(
                  _duration?.toHms() ?? '0:00',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //  shuffle button
                StreamBuilder<AudioServiceShuffleMode>(
                  stream: songRepository.shuffleMode,
                  builder: (context, snapshot) {
                    final shuffleMode =
                        snapshot.data ?? AudioServiceShuffleMode.none;

                    return IconButton(
                      onPressed: () {
                        if (shuffleMode == AudioServiceShuffleMode.none) {
                          songRepository
                              .setShuffleMode(AudioServiceShuffleMode.all);
                        } else {
                          songRepository
                              .setShuffleMode(AudioServiceShuffleMode.none);
                        }
                      },
                      icon: shuffleMode == AudioServiceShuffleMode.none
                          ? const Icon(Icons.shuffle_rounded)
                          : const Icon(Icons.shuffle_on_rounded),
                      iconSize: 40,
                    );
                  },
                ),
                // previous button
                IconButton(
                  onPressed: () {
                    songRepository.skipToPrevious();
                  },
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: 40,
                ),
                // play/pause button
                StreamBuilder<bool>(
                  stream: songRepository.playbackState.map(
                    (state) => state.playing,
                  ),
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () {
                        if (playing) {
                          songRepository.pause();
                        } else {
                          songRepository.play();
                        }
                      },
                      icon: playing
                          ? const Icon(Icons.pause_rounded)
                          : const Icon(Icons.play_arrow_rounded),
                      iconSize: 40,
                    );
                  },
                ),
                // next button
                IconButton(
                  onPressed: () {
                    songRepository.skipToNext();
                  },
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: 40,
                ),
                // queue button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.queue_music_rounded),
                  iconSize: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
