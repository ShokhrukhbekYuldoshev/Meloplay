import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/bloc/song/song_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/data/repositories/song_repository.dart';
import 'package:meloplay/src/presentation/widgets/animated_favorite_button.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({
    super.key,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final player = sl<JustAudioPlayer>();
  SequenceState? sequence;

  @override
  void initState() {
    super.initState();

    player.sequenceState.listen((state) {
      setState(() {
        sequence = state;
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
            StreamBuilder<SequenceState?>(
                stream: player.sequenceState,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final sequence = snapshot.data;

                  MediaItem? mediaItem =
                      sequence!.sequence[sequence.currentIndex].tag;

                  return Expanded(
                    flex: 4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        QueryArtworkWidget(
                          id: int.parse(mediaItem!.id),
                          type: ArtworkType.AUDIO,
                          size: 10000,
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
                                    .isFavorite(mediaItem.id),
                                onTap: () {
                                  context.read<SongBloc>().add(
                                        ToggleFavorite(mediaItem.id),
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
            StreamBuilder<SequenceState?>(
                stream: player.sequenceState,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final sequence = snapshot.data;

                  MediaItem? mediaItem =
                      sequence!.sequence[sequence.currentIndex].tag;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mediaItem!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              mediaItem.artist ?? 'Unknown',
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
              stream: player.position,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: player.duration,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position > duration
                              ? duration.inMilliseconds.toDouble()
                              : position.inMilliseconds.toDouble(),
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            context.read<PlayerBloc>().add(
                                  PlayerSeek(
                                    Duration(milliseconds: value.toInt()),
                                  ),
                                );
                          },
                        ),

                        // position and duration text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${position.inMinutes.toString().padLeft(2, '0')}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //  shuffle button
                StreamBuilder<bool>(
                  stream: player.shuffleModeEnabled,
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
                              Icons.shuffle_outlined,
                              color: Colors.grey,
                            )
                          : const Icon(Icons.shuffle_outlined),
                      iconSize: 30,
                    );
                  },
                ),
                // previous button
                IconButton(
                  onPressed: () {
                    context.read<PlayerBloc>().add(PlayerPrevious());
                  },
                  icon: const Icon(Icons.skip_previous_outlined),
                  iconSize: 40,
                ),
                // play/pause button
                StreamBuilder<bool>(
                  stream: player.playing,
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
                          ? const Icon(Icons.pause_outlined)
                          : const Icon(Icons.play_arrow_outlined),
                      iconSize: 40,
                    );
                  },
                ),
                // next button
                IconButton(
                  onPressed: () {
                    context.read<PlayerBloc>().add(PlayerNext());
                  },
                  icon: const Icon(Icons.skip_next_outlined),
                  iconSize: 40,
                ),
                // repeat button
                StreamBuilder<LoopMode>(
                  stream: player.loopMode,
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
                              Icons.repeat_outlined,
                              color: Colors.grey,
                            )
                          : snapshot.data == LoopMode.all
                              ? const Icon(Icons.repeat_outlined)
                              : const Icon(Icons.repeat_one_outlined),
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
