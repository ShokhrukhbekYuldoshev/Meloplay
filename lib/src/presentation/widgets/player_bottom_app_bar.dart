import 'dart:ui';

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
import 'package:meloplay/src/presentation/widgets/seek_bar.dart';
import 'package:meloplay/src/presentation/widgets/spinning_disc_animation.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
  bool isExpanded = false;

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
    return SizedBox(
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return StreamBuilder<SequenceState?>(
            stream: player.sequenceState,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final sequence = snapshot.data;
              MediaItem mediaItem =
                  sequence?.sequence[sequence.currentIndex].tag;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.of(context).pushNamed(
                    AppRouter.playerRoute,
                  );
                },
                // slide up to show player
                onVerticalDragUpdate: (details) {
                  bool previousIsExpanded = isExpanded;
                  if (details.delta.dy > 0) {
                    isExpanded = false;
                  } else {
                    isExpanded = true;
                  }
                  if (previousIsExpanded != isExpanded) {
                    setState(() {});
                  }
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: isExpanded ? 264 : 60,
                    child: BottomAppBar(
                      color: Themes.getTheme().primaryColor,
                      padding: const EdgeInsets.all(0),
                      child: isExpanded
                          ? _buildExpanded(sequence!, mediaItem)
                          : _buildCollapsed(sequence!, mediaItem),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  _buildExpanded(SequenceState sequence, MediaItem mediaItem) {
    return Stack(
      children: [
        QueryArtworkWidget(
          keepOldArtwork: true,
          artworkHeight: double.infinity,
          artworkWidth: double.infinity,
          id: int.parse(mediaItem.id),
          type: ArtworkType.AUDIO,
          size: 10000,
          artworkBorder: BorderRadius.circular(0),
          nullArtworkWidget: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(0),
            ),
            child: const Icon(
              Icons.music_note_outlined,
              size: 100,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Text(
                  mediaItem.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mediaItem.artist ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                SeekBar(player: player),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // previous button
                    IconButton(
                      onPressed: () {
                        context
                            .read<bloc.PlayerBloc>()
                            .add(bloc.PlayerPrevious());
                      },
                      icon: const Icon(
                        Icons.skip_previous_outlined,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      tooltip: 'Previous',
                    ),
                    const SizedBox(width: 20),
                    // play/pause button
                    StreamBuilder<bool>(
                      stream: player.playing,
                      builder: (context, snapshot) {
                        final playing = snapshot.data ?? false;
                        return IconButton(
                          onPressed: () {
                            if (playing) {
                              context
                                  .read<bloc.PlayerBloc>()
                                  .add(bloc.PlayerPause());
                            } else {
                              context
                                  .read<bloc.PlayerBloc>()
                                  .add(bloc.PlayerPlay());
                            }
                          },
                          icon: playing
                              ? const Icon(
                                  Icons.pause_outlined,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.play_arrow_outlined,
                                  color: Colors.white,
                                ),
                          iconSize: 40,
                          tooltip: 'Play/Pause',
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    // next button
                    IconButton(
                      onPressed: () {
                        context.read<bloc.PlayerBloc>().add(bloc.PlayerNext());
                      },
                      icon: const Icon(
                        Icons.skip_next_outlined,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      tooltip: 'Next',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildCollapsed(SequenceState sequence, MediaItem mediaItem) {
    return Row(
      children: [
        const SizedBox(width: 20),
        // song info with swiping
        Expanded(
          child: SwipeSong(
            sequence: sequence,
            mediaItem: mediaItem,
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
                  context.read<bloc.PlayerBloc>().add(bloc.PlayerPause());
                } else {
                  context.read<bloc.PlayerBloc>().add(bloc.PlayerPlay());
                }
              },
              icon: playing
                  ? const Icon(Icons.pause_outlined)
                  : const Icon(Icons.play_arrow_outlined),
            );
          },
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRouter.queueRoute,
            );
          },
          icon: const Icon(Icons.queue_music_outlined),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class SwipeSong extends StatefulWidget {
  const SwipeSong({
    super.key,
    required this.sequence,
    required this.mediaItem,
  });

  final SequenceState? sequence;
  final MediaItem mediaItem;

  @override
  State<SwipeSong> createState() => _SwipeSongState();
}

class _SwipeSongState extends State<SwipeSong> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.sequence?.currentIndex ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: sl<JustAudioPlayer>().currentIndex,
      builder: (context, snapshot) {
        if (snapshot.hasData && pageController.hasClients) {
          pageController.jumpToPage(snapshot.data!);
        }
        return PageView.builder(
          itemCount: widget.sequence?.sequence.length ?? 0,
          controller: pageController,
          onPageChanged: (index) {
            if (widget.sequence?.currentIndex != index) {
              context.read<bloc.PlayerBloc>().add(
                    bloc.PlayerSeek(
                      Duration.zero,
                      index: index,
                    ),
                  );
            }
          },
          itemBuilder: (context, index) {
            MediaItem mediaItem = widget.sequence?.sequence[index].tag;
            return Row(
              children: [
                SpinningDisc(
                  id: int.parse(mediaItem.id),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(width: 16),
              ],
            );
          },
        );
      },
    );
  }
}
