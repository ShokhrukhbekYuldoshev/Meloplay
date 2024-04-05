import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:meloplay/src/bloc/player/player_bloc.dart' as bloc;
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/presentation/widgets/spinning_disc_animation.dart';

class PlayerBottomAppBar extends StatefulWidget {
  const PlayerBottomAppBar({
    super.key,
  });

  @override
  State<PlayerBottomAppBar> createState() => _PlayerBottomAppBarState();
}

class _PlayerBottomAppBarState extends State<PlayerBottomAppBar> {
  final player = sl<JustAudioPlayer>();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    player.playing.listen((playing) {
      setState(() {
        isPlaying = playing;
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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return BlocBuilder<bloc.PlayerBloc, bloc.PlayerState>(
          builder: (context, state) {
            return StreamBuilder<SequenceState?>(
              stream: player.sequenceState,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final sequence = snapshot.data;
                MediaItem? mediaItem =
                    sequence?.sequence[sequence.currentIndex].tag;

                final pageController = PageController(
                  initialPage: sequence?.currentIndex ?? 0,
                );
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.of(context).pushNamed(
                      AppRouter.playerRoute,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                        32,
                      ),
                      topRight: Radius.circular(
                        32,
                      ),
                    ),
                    child: BottomAppBar(
                      color: Themes.getTheme().primaryColor,
                      child: StreamBuilder<int?>(
                        stream: player.currentIndex,
                        builder: (context, snapshot) {
                          final currentIndex = snapshot.data ?? 0;
                          return PageView.builder(
                            itemCount: sequence?.sequence.length,
                            controller: pageController,
                            onPageChanged: (index) async {
                              // if swiped right to left (next song)
                              if (index > currentIndex) {
                                context
                                    .read<bloc.PlayerBloc>()
                                    .add(bloc.PlayerNext());
                              }
                              // if swiped left to right (previous song)
                              else if (index < currentIndex) {
                                context
                                    .read<bloc.PlayerBloc>()
                                    .add(bloc.PlayerPrevious());
                              }
                            },
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // spinning disc
                                        SpinningDisc(
                                          id: int.parse(
                                            mediaItem!.id,
                                          ),
                                        ),

                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mediaItem.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                mediaItem.artist ?? 'Unknown',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Themes.getTheme()
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // play/pause button
                                  StreamBuilder<bool>(
                                    stream: player.playing,
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? false;
                                      return IconButton(
                                        onPressed: () {
                                          if (playing) {
                                            player.pause();
                                          } else {
                                            player.play();
                                          }
                                        },
                                        icon: playing
                                            ? const Icon(Icons.pause_outlined)
                                            : const Icon(
                                                Icons.play_arrow_outlined),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon:
                                        const Icon(Icons.queue_music_outlined),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
