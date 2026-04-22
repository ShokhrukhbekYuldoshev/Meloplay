import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
import 'package:meloplay/src/features/player/bloc/player/player_bloc.dart'
    as bloc;
import 'package:meloplay/src/core/shared/buttons/next_button.dart';
import 'package:meloplay/src/core/shared/buttons/play_pause_button.dart';
import 'package:meloplay/src/core/shared/buttons/previous_button.dart';
import 'package:meloplay/src/core/shared/buttons/repeat_button.dart';
import 'package:meloplay/src/core/shared/buttons/shuffle_button.dart';
import 'package:meloplay/src/core/shared/sleep_timer_dialog.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:meloplay/src/features/playlists/bloc/song/song_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/core/services/music_player.dart';
import 'package:meloplay/src/features/playlists/data/repositories/song_repository.dart';
import 'package:meloplay/src/core/shared/buttons/animated_favorite_button.dart';
import 'package:meloplay/src/core/shared/seek_bar.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  final player = sl<MusicPlayer>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: StreamBuilder<SequenceState?>(
        stream: player.sequenceState,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sequence = snapshot.data;
          final mediaItem = sequence!.currentSource?.tag as MediaItem?;

          if (mediaItem == null) {
            return const SizedBox.shrink();
          }

          return _buildPlayerContent(mediaItem);
        },
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Now Playing',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      actions: [
        IconButton(
          icon: BlocBuilder<bloc.PlayerBloc, bloc.PlayerState>(
            builder: (context, state) {
              return Icon(
                state.isSleepTimerActive
                    ? Icons.bedtime
                    : Icons.bedtime_outlined,
                color: state.isSleepTimerActive
                    ? Theme.of(context).colorScheme.primary
                    : null,
              );
            },
          ),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) => SleepTimerDialog(),
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            );
          },
          tooltip: 'Sleep Timer',
        ),
      ],
    );
  }

  Widget _buildPlayerContent(MediaItem mediaItem) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          32,
          16,
          32,
          MediaQuery.of(context).padding.bottom + 32,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildLargeScreenLayout(mediaItem);
            }
            return _buildSmallScreenLayout(mediaItem);
          },
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(MediaItem mediaItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Artwork
        Expanded(child: _buildArtwork(mediaItem, isLarge: true)),
        const SizedBox(width: 32),
        // Info section
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildTitleAndArtist(mediaItem),
              const SizedBox(height: 32),
              SeekBar(player: player),
              const SizedBox(height: 32),
              _buildControlButtons(),
              // Sleep Timer Indicator
              SleepTimerIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout(MediaItem mediaItem) {
    return Column(
      children: [
        // Artwork
        _buildArtwork(mediaItem, isLarge: false),

        const SizedBox(height: 24),

        // Title and artist
        _buildTitleAndArtist(mediaItem, centerAlign: true),

        const SizedBox(height: 32),

        SeekBar(player: player),

        const SizedBox(height: 32),

        _buildControlButtons(),

        // Sleep Timer Indicator
        SleepTimerIndicator(),
      ],
    );
  }

  Widget _buildArtwork(MediaItem mediaItem, {required bool isLarge}) {
    final size = isLarge
        ? MediaQuery.of(context).size.width / 3
        : MediaQuery.of(context).size.width - 64;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            QueryArtworkWidget(
              keepOldArtwork: true,
              id: int.parse(mediaItem.id),
              type: ArtworkType.AUDIO,
              size: 500,
              artworkWidth: double.infinity,
              artworkHeight: double.infinity,
              nullArtworkWidget: Container(
                color: Colors.grey.withValues(alpha: 0.1),
                child: Icon(
                  Icons.music_note_outlined,
                  size: size / 4,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: BlocBuilder<SongBloc, SongState>(
                builder: (context, state) {
                  return AnimatedFavoriteButton(
                    isFavorite: sl<SongRepository>().isFavorite(mediaItem.id),
                    mediaItem: mediaItem,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndArtist(MediaItem mediaItem, {bool centerAlign = false}) {
    return StreamBuilder<SequenceState?>(
      stream: player.sequenceState,
      builder: (context, snapshot) {
        final currentMediaItem =
            snapshot.data?.currentSource?.tag as MediaItem?;
        final displayItem = currentMediaItem ?? mediaItem;

        final titleWidget = _buildAnimatedTitle(
          displayItem.title,
          fontSize: centerAlign ? 24 : 20,
        );
        final artistWidget = _buildAnimatedArtist(
          displayItem.artist ?? 'Unknown',
          fontSize: centerAlign ? 18 : 16,
        );

        if (centerAlign) {
          return Column(
            children: [titleWidget, const SizedBox(height: 8), artistWidget],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [titleWidget, const SizedBox(height: 4), artistWidget],
        );
      },
    );
  }

  Widget _buildAnimatedTitle(String title, {required double fontSize}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: fontSize + 10,
        child: AutoSizeText(
          title,
          key: ValueKey(title),
          maxLines: 1,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          minFontSize: fontSize,
          overflowReplacement: Marquee(
            text: title,
            blankSpace: 100,
            startAfter: const Duration(seconds: 2),
            pauseAfterRound: const Duration(seconds: 2),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedArtist(String artist, {required double fontSize}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: fontSize + 10,
        child: AutoSizeText(
          artist,
          key: ValueKey(artist),
          maxLines: 1,
          style: TextStyle(fontSize: fontSize, color: Colors.grey.shade400),
          minFontSize: fontSize,
          overflowReplacement: Marquee(
            text: artist,
            blankSpace: 100,
            startAfter: const Duration(seconds: 2),
            pauseAfterRound: const Duration(seconds: 2),
            style: TextStyle(fontSize: fontSize, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const ShuffleButton(),
        const PreviousButton(),
        const PlayPauseButton(),
        const NextButton(),
        const RepeatButton(),
      ],
    );
  }
}

class SleepTimerIndicator extends StatelessWidget {
  const SleepTimerIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<bloc.PlayerBloc, bloc.PlayerState>(
      builder: (context, state) {
        if (!state.isSleepTimerActive || state.sleepTimerRemaining == null) {
          return const SizedBox.shrink();
        }

        final remaining = state.sleepTimerRemaining!;
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds.remainder(60);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bedtime, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Sleep timer: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<bloc.PlayerBloc>().add(
                  bloc.CancelSleepTimer(),
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
