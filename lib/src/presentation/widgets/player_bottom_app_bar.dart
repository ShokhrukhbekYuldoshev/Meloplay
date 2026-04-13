import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'package:meloplay/src/bloc/player/player_bloc.dart' as bloc;
import 'package:meloplay/src/bloc/theme/theme_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/helpers/show_player_sheet.dart';
import 'package:meloplay/src/core/router/app_router.dart';
import 'package:meloplay/src/core/theme/themes.dart';
import 'package:meloplay/src/data/services/music_player.dart';
import 'package:meloplay/src/data/repositories/recents_repository.dart';
import 'package:meloplay/src/presentation/widgets/buttons/play_pause_button.dart';
import 'package:meloplay/src/presentation/widgets/spinning_disc.dart';

class PlayerBottomAppBar extends StatefulWidget {
  const PlayerBottomAppBar({super.key});

  @override
  State<PlayerBottomAppBar> createState() => _PlayerBottomAppBarState();
}

class _PlayerBottomAppBarState extends State<PlayerBottomAppBar> {
  final player = sl<MusicPlayer>();
  late final StreamSubscription<bool> _playingSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _playingSubscription = player.playing.listen((playing) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _playingSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializePlaylist() async {
    // Prevent multiple simultaneous initialization attempts
    if (_isLoading) return;

    _isLoading = true; // Don't use setState here

    try {
      final playlist = await player.loadPlaylist();

      if (playlist.isEmpty) {
        debugPrint('Playlist is empty, nothing to initialize');
        return;
      }

      final lastPlayedSong = await sl<RecentsRepository>().fetchLastPlayed();

      if (lastPlayedSong != null) {
        // Check if the last played song exists in the current playlist
        final songExists = playlist.any((song) => song.id == lastPlayedSong.id);

        if (songExists) {
          await player.setSequenceFromPlaylist(playlist, lastPlayedSong);
          debugPrint(
            'Playlist initialized with last played song: ${lastPlayedSong.title}',
          );
        } else {
          // Last played song not in playlist, just load the playlist
          await player.setSequenceFromPlaylist(playlist, playlist.first);
          debugPrint(
            'Last played song not found in playlist, starting from first song',
          );
        }
      } else {
        // No last played song, just load the playlist from the beginning
        await player.setSequenceFromPlaylist(playlist, playlist.first);
        debugPrint('Playlist initialized from beginning');
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing playlist: $e');
      debugPrint('StackTrace: $stackTrace');
    } finally {
      if (mounted) {
        _isLoading = false; // Don't use setState here either
      }
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
              if (snapshot.connectionState == ConnectionState.waiting &&
                  player.playlist.isEmpty) {
                _initializePlaylist();
                return const SizedBox.shrink();
              }

              if (snapshot.hasError) {
                return const SizedBox.shrink();
              }

              final sequence = snapshot.data;
              final mediaItem = sequence?.currentSource?.tag as MediaItem?;

              if (mediaItem == null || sequence == null) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showPlayerSheet(context),
                onVerticalDragUpdate: (details) {
                  // Detect a significant upward drag to open the player sheet
                  if (details.delta.dy < -10) {
                    showPlayerSheet(context);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: FakeGlass(
                    shape: LiquidRoundedSuperellipse(borderRadius: 32),
                    child: Container(
                      height: 60,
                      color: Themes.getTheme().primaryColor.withValues(
                        alpha: 0.5,
                      ),
                      child: _buildBottomAppBar(sequence, mediaItem),
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

  Row _buildBottomAppBar(SequenceState sequence, MediaItem mediaItem) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: SwipeSong(
            sequence: sequence,
            mediaItem: mediaItem,
            key: ValueKey(sequence.currentIndex),
          ),
        ),
        PlayPauseButton(
          width: 20,
          color: Theme.of(context).textTheme.bodyMedium!.color!,
        ),
        IconButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRouter.queueRoute),
          icon: const Icon(Icons.queue_music_outlined),
          tooltip: 'Queue',
          splashRadius: 24,
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class SwipeSong extends StatefulWidget {
  const SwipeSong({super.key, required this.sequence, required this.mediaItem});

  final SequenceState sequence;
  final MediaItem mediaItem;

  @override
  State<SwipeSong> createState() => _SwipeSongState();
}

class _SwipeSongState extends State<SwipeSong> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isPageChanging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.sequence.currentIndex!;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(SwipeSong oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle sequence changes (like playlist updates)
    if (oldWidget.sequence.currentIndex != widget.sequence.currentIndex &&
        _pageController.hasClients &&
        !_isPageChanging) {
      _currentIndex = widget.sequence.currentIndex!;
      _pageController.jumpToPage(_currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: sl<MusicPlayer>().currentIndex,
      builder: (context, snapshot) {
        final newIndex = snapshot.data;
        if (newIndex != null &&
            newIndex != _currentIndex &&
            _pageController.hasClients &&
            !_isPageChanging) {
          _currentIndex = newIndex;
          _pageController.jumpToPage(newIndex);
        }

        return PageView.builder(
          itemCount: widget.sequence.sequence.length,
          controller: _pageController,
          physics:
              const ClampingScrollPhysics(), // Better for horizontal swiping
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) => _buildSongItem(index),
        );
      },
    );
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index && !_isPageChanging) {
      _isPageChanging = true;
      _currentIndex = index;

      context.read<bloc.PlayerBloc>().add(
        bloc.PlayerSeek(Duration.zero, index: index),
      );

      // Reset flag after navigation completes
      Future.microtask(() {
        if (mounted) {
          _isPageChanging = false;
        }
      });
    }
  }

  Widget _buildSongItem(int index) {
    final mediaItem = widget.sequence.sequence[index].tag as MediaItem;
    final isCurrentSong = index == widget.sequence.currentIndex;

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
                style: TextStyle(
                  fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.w500,
                  color: isCurrentSong
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mediaItem.artist?.isNotEmpty == true
                    ? mediaItem.artist!
                    : 'Unknown Artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
