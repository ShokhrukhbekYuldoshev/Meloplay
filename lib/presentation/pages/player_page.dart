import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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

    songRepository.mediaItem.listen((mediaItem) async {
      if (mediaItem != null) {
        // if media item is same skip
        if (mediaItem.id != widget.mediaItem.id) {
          try {
            int index = songRepository.getMediaItemIndex(widget.mediaItem);
            await songRepository.playFromQueue(index);
          } catch (_) {}
        }

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
            StreamBuilder<MediaItem?>(
                stream: songRepository.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  return Expanded(
                    flex: 4,
                    child: QueryArtworkWidget(
                      id: int.parse(mediaItem?.id ?? '0'),
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
                  );
                }),
            const Spacer(),
            // title and artist
            StreamBuilder<MediaItem?>(
                stream: songRepository.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mediaItem?.title ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              mediaItem?.artist ?? 'Unknown',
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
                  );
                }),
            const Spacer(),
            // seek bar
            StreamBuilder<Duration>(
              stream: songRepository.position,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                try {
                  return Slider(
                    value: position.inMilliseconds.toDouble(),
                    min: 0,
                    max: _duration?.inMilliseconds.toDouble() ?? 0,
                    onChanged: (value) {
                      songRepository
                          .seek(Duration(milliseconds: value.toInt()));
                    },
                  );
                } catch (e) {
                  return Slider(
                    value: 0,
                    min: 0,
                    max: 0,
                    onChanged: (value) {},
                  );
                }
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

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //  shuffle button
                StreamBuilder<bool>(
                  stream: songRepository.shuffleModeEnabled,
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: () async {
                        await songRepository.setShuffleModeEnabled(
                          !(snapshot.data ?? false),
                        );
                      },
                      icon: snapshot.data == false
                          ? const Icon(
                              Icons.shuffle_rounded,
                              color: Colors.grey,
                            )
                          : const Icon(Icons.shuffle_rounded),
                      iconSize: 30,
                    );
                  },
                ),
                // previous button
                IconButton(
                  onPressed: () async {
                    await songRepository.seekPrevious();
                  },
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: 40,
                ),
                // play/pause button
                StreamBuilder<bool>(
                  stream: songRepository.playing,
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () async {
                        if (playing) {
                          await songRepository.pause();
                        } else {
                          await songRepository.play();
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
                    songRepository.seekNext();
                  },
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: 40,
                ),
                // repeat button
                StreamBuilder<LoopMode>(
                    stream: songRepository.loopMode,
                    builder: (context, snapshot) {
                      return IconButton(
                        onPressed: () async {
                          if (snapshot.data == LoopMode.off) {
                            await songRepository.setLoopMode(LoopMode.all);
                          } else if (snapshot.data == LoopMode.all) {
                            await songRepository.setLoopMode(LoopMode.one);
                          } else {
                            await songRepository.setLoopMode(LoopMode.off);
                          }
                        },
                        icon: snapshot.data == LoopMode.off
                            ? const Icon(
                                Icons.repeat_rounded,
                                color: Colors.grey,
                              )
                            : snapshot.data == LoopMode.all
                                ? const Icon(Icons.repeat_rounded)
                                : const Icon(Icons.repeat_one_rounded),
                        iconSize: 30,
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
