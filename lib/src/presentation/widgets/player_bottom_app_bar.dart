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
import 'package:meloplay/src/data/repositories/recents_repository.dart';
import 'package:meloplay/src/presentation/widgets/buttons/play_pause_button.dart';
import 'package:meloplay/src/presentation/widgets/spinning_disc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerBottomAppBar extends StatefulWidget {
  const PlayerBottomAppBar({super.key});

  @override
  State<PlayerBottomAppBar> createState() => _PlayerBottomAppBarState();
}

class _PlayerBottomAppBarState extends State<PlayerBottomAppBar> {
  final player = sl<MusicPlayer>();
  bool isPlaying = false;

  List<SongModel> playlist = [];

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

  Future<void> _getPlaylist() async {
    playlist = await player.loadPlaylist();
    if (playlist.isEmpty) {
      return;
    }
    // get last played song
    SongModel? lastPlayedSong = await sl<RecentsRepository>().fetchLastPlayed();
    if (lastPlayedSong != null) {
      await player.setSequenceFromPlaylist(playlist, lastPlayedSong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return StreamBuilder<SequenceState?>(
            stream: player.sequenceState,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                // if no sequence is loaded, load from hive
                if (player.playlist.isEmpty) {
                  _getPlaylist();
                }
                return const SizedBox();
              }

              var sequence = snapshot.data;
              MediaItem? mediaItem = sequence!.currentSource?.tag as MediaItem?;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  Navigator.of(context).pushNamed(AppRouter.playerRoute);
                },
                // slide up to player page
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < 0) {
                    Navigator.of(context).pushNamed(AppRouter.playerRoute);
                  }
                },
                child: mediaItem == null
                    ? const SizedBox()
                    : ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(50),
                        ),
                        child: Container(
                          height: 60,
                          color: Themes.getTheme().primaryColor,
                          child: _buildBottomAppBar(sequence, mediaItem),
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Row _buildBottomAppBar(SequenceState sequence, MediaItem mediaItem) {
    return Row(
      children: [
        const SizedBox(width: 20),
        // song info with swiping
        Expanded(
          child: SwipeSong(sequence: sequence, mediaItem: mediaItem),
        ),
        PlayPauseButton(
          width: 20,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.queueRoute);
          },
          icon: const Icon(Icons.queue_music_outlined),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class SwipeSong extends StatefulWidget {
  const SwipeSong({super.key, required this.sequence, required this.mediaItem});

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
      stream: sl<MusicPlayer>().currentIndex,
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
                bloc.PlayerSeek(Duration.zero, index: index),
              );
            }
          },
          itemBuilder: (context, index) {
            MediaItem mediaItem = widget.sequence?.sequence[index].tag;
            return Row(
              children: [
                SpinningDisc(id: int.parse(mediaItem.id)),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        mediaItem.artist ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Themes.getTheme().colorScheme.onSurface
                              .withValues(alpha: 0.7),
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
