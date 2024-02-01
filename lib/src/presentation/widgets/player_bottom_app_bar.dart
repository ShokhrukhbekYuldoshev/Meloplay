import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meloplay/src/bloc/player/player_bloc.dart';
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/data/repositories/player_repository.dart';
import 'package:meloplay/src/presentation/utils/app_router.dart';
import 'package:meloplay/src/presentation/utils/theme/themes.dart';
import 'package:meloplay/src/presentation/widgets/spinning_disc_animation.dart';
import 'package:meloplay/src/service_locator.dart';

class PlayerBottomAppBar extends StatefulWidget {
  const PlayerBottomAppBar({
    super.key,
  });

  @override
  State<PlayerBottomAppBar> createState() => _PlayerBottomAppBarState();
}

class _PlayerBottomAppBarState extends State<PlayerBottomAppBar> {
  final playerRepository = sl<PlayerRepository>();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    playerRepository.playing.listen((playing) {
      setState(() {
        isPlaying = playing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            return StreamBuilder<MediaItem?>(
              stream: playerRepository.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;

                if (mediaItem == null) {
                  return const SizedBox.shrink();
                } else {
                  final pageController = PageController(
                    initialPage: playerRepository.mediaItems.indexOf(mediaItem),
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      Navigator.pushNamed(
                        context,
                        AppRouter.playerRoute,
                        arguments: await playerRepository.mediaItem.first,
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
                            stream: playerRepository.currentIndex,
                            builder: (context, snapshot) {
                              final currentIndex = snapshot.data ?? 0;
                              return PageView.builder(
                                itemCount: playerRepository.mediaItems.length,
                                controller: pageController,
                                onPageChanged: (index) async {
                                  // if swiped right to left (next song)
                                  if (index > currentIndex) {
                                    context
                                        .read<PlayerBloc>()
                                        .add(PlayerNext());
                                  }
                                  // if swiped left to right (previous song)
                                  else if (index < currentIndex) {
                                    context
                                        .read<PlayerBloc>()
                                        .add(PlayerPrevious());
                                  }
                                },
                                itemBuilder: (context, index) {
                                  // Get the mediaItem for the song at the current index
                                  // var mediaItem = songRepository.mediaItems[index];

                                  return Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // spinning disc
                                            SpinningDisc(
                                              id: int.parse(
                                                mediaItem.id,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    mediaItem.artist ??
                                                        'Unknown',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                        stream: playerRepository.playing,
                                        builder: (context, snapshot) {
                                          final playing =
                                              snapshot.data ?? false;
                                          return IconButton(
                                            onPressed: () {
                                              if (playing) {
                                                playerRepository.pause();
                                              } else {
                                                playerRepository.play();
                                              }
                                            },
                                            icon: playing
                                                ? const Icon(
                                                    Icons.pause_rounded)
                                                : const Icon(
                                                    Icons.play_arrow_rounded),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons.queue_music_outlined),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  );
                                },
                              );
                            }),
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
