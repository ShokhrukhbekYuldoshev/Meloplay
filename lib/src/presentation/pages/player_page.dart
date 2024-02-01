import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/bloc/song/song_bloc.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/data/repositories/song_repository.dart';
import 'package:meloplay/src/presentation/widgets/animated_favorite_button.dart';
import 'package:meloplay/src/presentation/utils/extensions.dart';
import 'package:meloplay/src/presentation/utils/theme/themes.dart';
import 'package:meloplay/src/service_locator.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerPage extends StatefulWidget {
  final MediaItem mediaItem;
  const PlayerPage({
    super.key,
    required this.mediaItem,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final playerRepository = sl<PlayerRepository>();

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  Future<void> initPlayer() async {
    playerRepository.mediaItem.listen(
      (mediaItem) async {
        if (mediaItem != null) {
          // if media item is same skip or no items playing
          if (mediaItem.id != widget.mediaItem.id ||
              await playerRepository.playing.first == false) {
            try {
              int index = playerRepository.getMediaItemIndex(widget.mediaItem);
              await playerRepository.playFromQueue(index);
            } catch (_) {}
          }
        }
      },
    );
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
                stream: playerRepository.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;

                  return Expanded(
                    flex: 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        QueryArtworkWidget(
                          id: int.parse(mediaItem?.id ?? '0'),
                          type: ArtworkType.AUDIO,
                          artworkQuality: FilterQuality.high,
                          quality: 100,
                          artworkWidth: double.infinity,
                          nullArtworkWidget: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.music_note_outlined,
                              size: MediaQuery.of(context).size.height / 10,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: BlocBuilder<SongBloc, SongState>(
                            builder: (context, state) {
                              return AnimatedFavoriteButton(
                                isFavorite: sl<SongRepository>()
                                    .isFavorite(mediaItem?.id ?? ''),
                                onTap: () {
                                  context.read<SongBloc>().add(
                                        ToggleFavorite(mediaItem?.id ?? ''),
                                      );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            const Spacer(),
            // title and artist
            StreamBuilder<MediaItem?>(
                stream: playerRepository.mediaItem,
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
                    ],
                  );
                }),
            const Spacer(),
            // seek bar
            StreamBuilder<Duration>(
              stream: playerRepository.position,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                try {
                  return StreamBuilder<Duration?>(
                    stream: playerRepository.duration,
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      return Slider(
                        value: position.inMilliseconds.toDouble(),
                        min: 0,
                        max: duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          context.read<PlayerBloc>().add(
                                PlayerSeek(
                                  Duration(milliseconds: value.toInt()),
                                ),
                              );
                        },
                      );
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
                  stream: playerRepository.position,
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
                StreamBuilder<Duration?>(
                    stream: playerRepository.duration,
                    builder: (context, snapshot) {
                      final duration = snapshot.data;
                      return Text(
                        duration?.toHms() ?? '0:00',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
              ],
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //  shuffle button
                StreamBuilder<bool>(
                  stream: playerRepository.shuffleModeEnabled,
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: () async {
                        context.read<PlayerBloc>().add(
                              PlayerSetShuffleModeEnabled(
                                !(snapshot.data ?? false),
                              ),
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
                  onPressed: () {
                    context.read<PlayerBloc>().add(PlayerPrevious());
                  },
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: 40,
                ),
                // play/pause button
                StreamBuilder<bool>(
                  stream: playerRepository.playing,
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () {
                        if (playing) {
                          context.read<PlayerBloc>().add(PlayerPause());
                        } else {
                          context.read<PlayerBloc>().add(PlayerPlay());
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
                    context.read<PlayerBloc>().add(PlayerNext());
                  },
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: 40,
                ),
                // repeat button
                StreamBuilder<LoopMode>(
                  stream: playerRepository.loopMode,
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: () {
                        if (snapshot.data == LoopMode.off) {
                          context.read<PlayerBloc>().add(
                                PlayerSetLoopMode(LoopMode.all),
                              );
                        } else if (snapshot.data == LoopMode.all) {
                          context.read<PlayerBloc>().add(
                                PlayerSetLoopMode(LoopMode.one),
                              );
                        } else {
                          context.read<PlayerBloc>().add(
                                PlayerSetLoopMode(LoopMode.off),
                              );
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
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
