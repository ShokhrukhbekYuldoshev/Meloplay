import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:marquee/marquee.dart';
import 'package:meloplay/src/presentation/widgets/buttons/next_button.dart';
import 'package:meloplay/src/presentation/widgets/buttons/play_pause_button.dart';
import 'package:meloplay/src/presentation/widgets/buttons/previous_button.dart';
import 'package:meloplay/src/presentation/widgets/buttons/repeat_button.dart';
import 'package:meloplay/src/presentation/widgets/buttons/shuffle_button.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:meloplay/src/bloc/song/song_bloc.dart';
import 'package:meloplay/src/core/di/service_locator.dart';
import 'package:meloplay/src/data/services/music_player.dart';
import 'package:meloplay/src/data/repositories/song_repository.dart';
import 'package:meloplay/src/presentation/widgets/buttons/animated_favorite_button.dart';
import 'package:meloplay/src/presentation/widgets/seek_bar.dart';

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
        PopupMenuButton(
          icon: const Icon(Icons.more_vert_outlined, color: Colors.white),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: () => showSleepTimer(context),
                child: const Text('Sleep timer'),
              ),
              const PopupMenuItem(child: Text('Add to playlist')),
              const PopupMenuItem(child: Text('Share')),
            ];
          },
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

  void showSleepTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sleep Timer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...[
                  'Off',
                  '5 min',
                  '10 min',
                  '15 min',
                  '30 min',
                  '45 min',
                  '1 hour',
                ].map((duration) {
                  return ListTile(
                    title: Text(duration),
                    onTap: () => Navigator.of(context).pop(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
